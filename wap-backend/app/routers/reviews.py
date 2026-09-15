"""Review management endpoints for completed swaps."""

from typing import Optional, List
from datetime import datetime
from fastapi import APIRouter, HTTPException, Query
from google.cloud.firestore_v1.base_query import FieldFilter

from app.schemas import (
    ReviewCreate,
    ReviewResponse,
    ReviewListResponse,
)
from app.firebase_db import get_firebase_service

router = APIRouter(prefix="/reviews", tags=["reviews"])


def _convert_timestamp(value) -> Optional[str]:
    """Convert Firestore timestamp to ISO string."""
    if value is None:
        return None
    if hasattr(value, "isoformat"):
        return value.isoformat()
    return str(value)


def _enrich_review(review_data: dict, db) -> ReviewResponse:
    """Enrich review with reviewer profile info."""
    reviewer_uid = review_data.get("reviewer_uid")

    # Get reviewer profile
    reviewer_name = None
    reviewer_photo = None

    if reviewer_uid:
        profile_doc = db.collection("profiles").document(reviewer_uid).get()
        if profile_doc.exists:
            profile = profile_doc.to_dict()
            reviewer_name = profile.get("display_name") or profile.get("full_name")
            reviewer_photo = profile.get("photo_url")

    return ReviewResponse(
        id=review_data.get("id"),
        swap_request_id=review_data.get("swap_request_id"),
        reviewer_uid=reviewer_uid,
        reviewed_uid=review_data.get("reviewed_uid"),
        rating=review_data.get("rating"),
        review_text=review_data.get("review_text"),
        skill_exchanged=review_data.get("skill_exchanged"),
        hours_exchanged=review_data.get("hours_exchanged"),
        created_at=_convert_timestamp(review_data.get("created_at")) or datetime.utcnow().isoformat(),
        reviewer_name=reviewer_name,
        reviewer_photo=reviewer_photo,
    )


@router.post("", response_model=ReviewResponse)
def submit_review(
    review: ReviewCreate,
    uid: str = Query(..., description="UID of the reviewer"),
):
    """
    Submit a review for a completed swap.

    - Can only review swaps you participated in
    - Can only review swaps with 'completed' status
    - Can only submit one review per swap
    """
    firebase = get_firebase_service()
    db = firebase.db

    # Get the swap request
    swap_ref = db.collection("swap_requests").document(review.swap_request_id)
    swap_doc = swap_ref.get()

    if not swap_doc.exists:
        raise HTTPException(status_code=404, detail="Swap request not found")

    swap_data = swap_doc.to_dict()
    requester_uid = swap_data.get("requester_uid")
    recipient_uid = swap_data.get("recipient_uid")

    # Verify user was a participant
    if uid not in [requester_uid, recipient_uid]:
        raise HTTPException(status_code=403, detail="You can only review swaps you participated in")

    # Verify swap is completed
    if swap_data.get("status") != "completed":
        raise HTTPException(status_code=400, detail="Can only review completed swaps")

    # Determine who is being reviewed
    reviewed_uid = recipient_uid if uid == requester_uid else requester_uid

    # Check if user already submitted a review for this swap
    existing_reviews = list(db.collection("reviews").where(
        filter=FieldFilter("swap_request_id", "==", review.swap_request_id)
    ).where(
        filter=FieldFilter("reviewer_uid", "==", uid)
    ).limit(1).stream())

    if existing_reviews:
        raise HTTPException(status_code=400, detail="You have already reviewed this swap")

    # Get completion data for hours exchanged
    completion = swap_data.get("completion", {})
    final_hours = completion.get("final_hours", 1.0)

    # Determine skill exchanged (what the reviewer received)
    if uid == requester_uid:
        skill_exchanged = swap_data.get("requester_need")  # What requester needed/learned
    else:
        skill_exchanged = swap_data.get("requester_offer")  # What recipient received

    now = datetime.utcnow()

    # Create review document
    review_data = {
        "swap_request_id": review.swap_request_id,
        "reviewer_uid": uid,
        "reviewed_uid": reviewed_uid,
        "rating": review.rating,
        "review_text": review.review_text,
        "skill_exchanged": skill_exchanged,
        "hours_exchanged": final_hours,
        "created_at": now,
    }

    # Add to Firestore
    doc_ref = db.collection("reviews").add(review_data)
    review_data["id"] = doc_ref[1].id

    # Update the reviewed user's profile stats
    _update_user_review_stats(db, reviewed_uid)

    # Award credits to the reviewed user (credits are based on the review they received)
    _award_credits_for_review(db, reviewed_uid, final_hours, review.rating, skill_exchanged)

    return _enrich_review(review_data, db)


def _update_user_review_stats(db, uid: str):
    """Update a user's average rating and review count in their profile."""
    # Get all reviews for this user
    reviews = list(db.collection("reviews").where(
        filter=FieldFilter("reviewed_uid", "==", uid)
    ).stream())

    if not reviews:
        return

    ratings = [doc.to_dict().get("rating", 0) for doc in reviews]
    avg_rating = sum(ratings) / len(ratings) if ratings else 0.0
    review_count = len(ratings)

    # Update profile (using camelCase for frontend compatibility)
    profile_ref = db.collection("profiles").document(uid)
    profile_ref.update({
        "average_rating": round(avg_rating, 2),
        "avgRating": round(avg_rating, 2),  # Alias for frontend
        "review_count": review_count,
        "reviewsCount": review_count,  # Alias for frontend
        "updated_at": datetime.utcnow(),
    })


def _award_credits_for_review(db, uid: str, hours: float, rating: int, skill: Optional[str]):
    """
    Award swap credits to a user based on a review they received.

    Credits = hours * skill_multiplier * (rating / 3)

    Skill multiplier determined by looking at the skill level from completion data.
    Default to 1.0 (intermediate) if not found.
    """
    # Skill multipliers
    SKILL_MULTIPLIERS = {
        "beginner": 1.0,
        "intermediate": 1.5,
        "advanced": 2.0,
    }

    # Default multiplier
    skill_mult = 1.0  # Will be refined when we have skill level data

    # Rating factor: 5 stars = 1.67x, 3 stars = 1.0x, 1 star = 0.33x
    rating_factor = rating / 3.0

    # Calculate credits
    credits = round(hours * skill_mult * rating_factor)

    if credits < 1:
        credits = 1  # Minimum 1 credit

    # Update user's swap_credits
    profile_ref = db.collection("profiles").document(uid)
    profile_doc = profile_ref.get()

    if profile_doc.exists:
        current_credits = profile_doc.to_dict().get("swap_credits", 0)
        profile_ref.update({
            "swap_credits": current_credits + credits,
            "updated_at": datetime.utcnow(),
        })


@router.get("/user/{uid}", response_model=ReviewListResponse)
def get_user_reviews(
    uid: str,
    limit: int = Query(20, ge=1, le=100),
    offset: int = Query(0, ge=0),
):
    """
    Get reviews received by a user.

    Returns paginated list of reviews with average rating.
    """
    firebase = get_firebase_service()
    db = firebase.db

    # Query reviews for this user (sorted in Python to avoid index requirement)
    query = db.collection("reviews").where(
        filter=FieldFilter("reviewed_uid", "==", uid)
    )

    # Get all reviews and sort in Python
    all_reviews = list(query.stream())
    all_reviews.sort(
        key=lambda doc: doc.to_dict().get("created_at") or datetime.min,
        reverse=True
    )
    total = len(all_reviews)

    # Calculate average rating
    ratings = [doc.to_dict().get("rating", 0) for doc in all_reviews]
    avg_rating = sum(ratings) / len(ratings) if ratings else 0.0

    # Apply pagination
    paginated_docs = all_reviews[offset:offset + limit]

    # Enrich reviews
    reviews = []
    for doc in paginated_docs:
        data = doc.to_dict()
        data["id"] = doc.id
        reviews.append(_enrich_review(data, db))

    return ReviewListResponse(
        reviews=reviews,
        total=total,
        average_rating=round(avg_rating, 2),
    )


@router.get("/given/{uid}", response_model=ReviewListResponse)
def get_reviews_given(
    uid: str,
    limit: int = Query(20, ge=1, le=100),
    offset: int = Query(0, ge=0),
):
    """
    Get reviews given by a user.

    Returns paginated list of reviews the user has written.
    """
    firebase = get_firebase_service()
    db = firebase.db

    # Query reviews by this user (sorted in Python to avoid index requirement)
    query = db.collection("reviews").where(
        filter=FieldFilter("reviewer_uid", "==", uid)
    )

    # Get all reviews and sort in Python
    all_reviews = list(query.stream())
    all_reviews.sort(
        key=lambda doc: doc.to_dict().get("created_at") or datetime.min,
        reverse=True
    )
    total = len(all_reviews)

    # Calculate average rating given
    ratings = [doc.to_dict().get("rating", 0) for doc in all_reviews]
    avg_rating = sum(ratings) / len(ratings) if ratings else 0.0

    # Apply pagination
    paginated_docs = all_reviews[offset:offset + limit]

    # Enrich reviews
    reviews = []
    for doc in paginated_docs:
        data = doc.to_dict()
        data["id"] = doc.id
        reviews.append(_enrich_review(data, db))

    return ReviewListResponse(
        reviews=reviews,
        total=total,
        average_rating=round(avg_rating, 2),
    )


@router.get("/swap/{swap_request_id}")
def get_swap_reviews(
    swap_request_id: str,
    uid: str = Query(..., description="UID of the requesting user"),
):
    """
    Get all reviews for a specific swap.

    Returns reviews from both participants (if submitted).
    """
    firebase = get_firebase_service()
    db = firebase.db

    # Verify the swap exists and user is a participant
    swap_ref = db.collection("swap_requests").document(swap_request_id)
    swap_doc = swap_ref.get()

    if not swap_doc.exists:
        raise HTTPException(status_code=404, detail="Swap request not found")

    swap_data = swap_doc.to_dict()
    if uid not in [swap_data.get("requester_uid"), swap_data.get("recipient_uid")]:
        raise HTTPException(status_code=403, detail="You can only view reviews for swaps you participated in")

    # Get reviews for this swap
    reviews_query = db.collection("reviews").where(
        filter=FieldFilter("swap_request_id", "==", swap_request_id)
    ).stream()

    reviews = []
    for doc in reviews_query:
        data = doc.to_dict()
        data["id"] = doc.id
        reviews.append(_enrich_review(data, db))

    # Determine if current user has submitted their review
    user_has_reviewed = any(r.reviewer_uid == uid for r in reviews)

    return {
        "swap_request_id": swap_request_id,
        "reviews": reviews,
        "user_has_reviewed": user_has_reviewed,
        "can_review": swap_data.get("status") == "completed" and not user_has_reviewed,
    }
