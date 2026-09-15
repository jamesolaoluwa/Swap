"""Skill portfolio endpoints for user profiles."""

from typing import Optional, List, Dict, Any
from datetime import datetime
from collections import defaultdict
from fastapi import APIRouter, HTTPException, Query
from google.cloud.firestore_v1.base_query import FieldFilter

from app.schemas import (
    PortfolioResponse,
    VerifiedSkill,
    CompletedSwapSummary,
    ReviewResponse,
)
from app.firebase_db import get_firebase_service

router = APIRouter(prefix="/portfolio", tags=["portfolio"])


def _convert_timestamp(value) -> Optional[str]:
    """Convert Firestore timestamp to ISO string."""
    if value is None:
        return None
    if hasattr(value, "isoformat"):
        return value.isoformat()
    return str(value)


def _get_profile_info(db, uid: str) -> Dict[str, Any]:
    """Get basic profile info for a user."""
    profile_doc = db.collection("profiles").document(uid).get()
    if profile_doc.exists:
        return profile_doc.to_dict()
    return {}


@router.get("/user/{uid}", response_model=PortfolioResponse)
def get_user_portfolio(
    uid: str,
    include_swaps: bool = Query(True, description="Include recent completed swaps"),
    include_reviews: bool = Query(True, description="Include recent reviews"),
    swap_limit: int = Query(10, ge=1, le=50),
    review_limit: int = Query(5, ge=1, le=20),
):
    """
    Get comprehensive skill portfolio for a user.

    Includes:
    - Swap credits and points
    - Completion stats (total swaps, hours traded)
    - Average rating and review count
    - Verified skills (taught and learned through swaps)
    - Recent completed swaps
    - Recent reviews received
    """
    firebase = get_firebase_service()
    db = firebase.db

    # Get profile
    profile_ref = db.collection("profiles").document(uid)
    profile_doc = profile_ref.get()

    if not profile_doc.exists:
        raise HTTPException(status_code=404, detail="User not found")

    profile = profile_doc.to_dict()

    # Basic profile info
    display_name = profile.get("display_name") or profile.get("full_name")
    photo_url = profile.get("photo_url")

    # Stats from profile (maintained by other operations)
    swap_credits = profile.get("swap_credits", 0)
    swap_points = profile.get("swap_points", 0)
    completed_swap_count = profile.get("completed_swap_count", 0)
    total_hours_traded = profile.get("total_hours_traded", 0.0)
    average_rating = profile.get("average_rating", 0.0)
    review_count = profile.get("review_count", 0)
    member_since = _convert_timestamp(profile.get("created_at"))

    # Get completed swaps for this user (as requester or recipient)
    completed_swaps = []
    verified_skills_taught: Dict[str, Dict] = defaultdict(lambda: {
        "times_exchanged": 0,
        "total_hours": 0.0,
        "ratings": [],
        "last_used": None,
    })
    verified_skills_learned: Dict[str, Dict] = defaultdict(lambda: {
        "times_exchanged": 0,
        "total_hours": 0.0,
        "ratings": [],
        "last_used": None,
    })

    # Query completed swaps where user is requester
    requester_swaps = list(db.collection("swap_requests").where(
        filter=FieldFilter("requester_uid", "==", uid)
    ).where(
        filter=FieldFilter("status", "==", "completed")
    ).order_by("updated_at", direction="DESCENDING").limit(swap_limit * 2).stream())

    # Query completed swaps where user is recipient
    recipient_swaps = list(db.collection("swap_requests").where(
        filter=FieldFilter("recipient_uid", "==", uid)
    ).where(
        filter=FieldFilter("status", "==", "completed")
    ).order_by("updated_at", direction="DESCENDING").limit(swap_limit * 2).stream())

    # Process all swaps
    all_swap_docs = requester_swaps + recipient_swaps

    # Recalculate stats from actual data
    actual_completed_count = 0
    actual_hours = 0.0

    for doc in all_swap_docs:
        data = doc.to_dict()
        swap_id = doc.id

        is_requester = data.get("requester_uid") == uid
        partner_uid = data.get("recipient_uid") if is_requester else data.get("requester_uid")

        # Get completion data
        completion = data.get("completion", {})
        final_hours = completion.get("final_hours", 1.0)
        completed_at = data.get("updated_at") or data.get("completed_at")

        actual_completed_count += 1
        actual_hours += final_hours

        # Determine skills exchanged
        if is_requester:
            skill_taught = data.get("requester_offer")  # What requester offered
            skill_learned = data.get("requester_need")  # What requester needed
        else:
            skill_taught = data.get("requester_need")  # Recipient provided what requester needed
            skill_learned = data.get("requester_offer")  # Recipient learned what requester offered

        # Get partner info
        partner_profile = _get_profile_info(db, partner_uid)
        partner_name = partner_profile.get("display_name") or partner_profile.get("full_name")
        partner_photo = partner_profile.get("photo_url")

        # Get reviews for this swap to find ratings
        reviews = list(db.collection("reviews").where(
            filter=FieldFilter("swap_request_id", "==", swap_id)
        ).stream())

        rating_given = None
        rating_received = None

        for review_doc in reviews:
            review_data = review_doc.to_dict()
            if review_data.get("reviewer_uid") == uid:
                rating_given = review_data.get("rating")
            else:
                rating_received = review_data.get("rating")

        # Track verified skills
        if skill_taught:
            verified_skills_taught[skill_taught]["times_exchanged"] += 1
            verified_skills_taught[skill_taught]["total_hours"] += final_hours
            if rating_received:
                verified_skills_taught[skill_taught]["ratings"].append(rating_received)
            verified_skills_taught[skill_taught]["last_used"] = completed_at

        if skill_learned:
            verified_skills_learned[skill_learned]["times_exchanged"] += 1
            verified_skills_learned[skill_learned]["total_hours"] += final_hours
            if rating_given:
                verified_skills_learned[skill_learned]["ratings"].append(rating_given)
            verified_skills_learned[skill_learned]["last_used"] = completed_at

        # Add to completed swaps list
        completed_swaps.append({
            "swap_id": swap_id,
            "partner_uid": partner_uid,
            "partner_name": partner_name,
            "partner_photo": partner_photo,
            "skill_taught": skill_taught,
            "skill_learned": skill_learned,
            "hours_exchanged": final_hours,
            "rating_given": rating_given,
            "rating_received": rating_received,
            "completed_at": completed_at,
        })

    # Sort completed swaps by date and limit
    completed_swaps.sort(key=lambda x: x.get("completed_at") or "", reverse=True)
    completed_swaps = completed_swaps[:swap_limit]

    # Convert verified skills to response format
    verified_taught_list = []
    for skill_name, data in verified_skills_taught.items():
        ratings = data["ratings"]
        avg_rating = sum(ratings) / len(ratings) if ratings else 0.0
        verified_taught_list.append(VerifiedSkill(
            skill_name=skill_name,
            times_exchanged=data["times_exchanged"],
            total_hours=round(data["total_hours"], 1),
            average_rating=round(avg_rating, 2),
            last_used=_convert_timestamp(data["last_used"]),
        ))

    verified_learned_list = []
    for skill_name, data in verified_skills_learned.items():
        ratings = data["ratings"]
        avg_rating = sum(ratings) / len(ratings) if ratings else 0.0
        verified_learned_list.append(VerifiedSkill(
            skill_name=skill_name,
            times_exchanged=data["times_exchanged"],
            total_hours=round(data["total_hours"], 1),
            average_rating=round(avg_rating, 2),
            last_used=_convert_timestamp(data["last_used"]),
        ))

    # Sort by times exchanged
    verified_taught_list.sort(key=lambda x: x.times_exchanged, reverse=True)
    verified_learned_list.sort(key=lambda x: x.times_exchanged, reverse=True)

    # Get recent reviews if requested
    recent_reviews = []
    if include_reviews:
        reviews_query = db.collection("reviews").where(
            filter=FieldFilter("reviewed_uid", "==", uid)
        ).order_by("created_at", direction="DESCENDING").limit(review_limit)

        for doc in reviews_query.stream():
            data = doc.to_dict()
            reviewer_uid = data.get("reviewer_uid")
            reviewer_profile = _get_profile_info(db, reviewer_uid)

            recent_reviews.append(ReviewResponse(
                id=doc.id,
                swap_request_id=data.get("swap_request_id"),
                reviewer_uid=reviewer_uid,
                reviewed_uid=uid,
                rating=data.get("rating"),
                review_text=data.get("review_text"),
                skill_exchanged=data.get("skill_exchanged"),
                hours_exchanged=data.get("hours_exchanged"),
                created_at=_convert_timestamp(data.get("created_at")) or datetime.utcnow().isoformat(),
                reviewer_name=reviewer_profile.get("display_name") or reviewer_profile.get("full_name"),
                reviewer_photo=reviewer_profile.get("photo_url"),
            ))

    # Build completed swap summaries
    recent_swaps = []
    if include_swaps:
        for swap in completed_swaps:
            recent_swaps.append(CompletedSwapSummary(
                swap_request_id=swap["swap_id"],
                partner_uid=swap["partner_uid"],
                partner_name=swap["partner_name"],
                partner_photo=swap["partner_photo"],
                skill_taught=swap["skill_taught"],
                skill_learned=swap["skill_learned"],
                hours_exchanged=swap["hours_exchanged"],
                rating_given=swap["rating_given"],
                rating_received=swap["rating_received"],
                completed_at=_convert_timestamp(swap["completed_at"]) or datetime.utcnow().isoformat(),
            ))

    # Update profile stats if they differ from calculated values
    if actual_completed_count != completed_swap_count or abs(actual_hours - total_hours_traded) > 0.1:
        profile_ref.update({
            "completed_swap_count": actual_completed_count,
            "total_hours_traded": round(actual_hours, 1),
            "updated_at": datetime.utcnow(),
        })
        completed_swap_count = actual_completed_count
        total_hours_traded = actual_hours

    return PortfolioResponse(
        uid=uid,
        display_name=display_name,
        photo_url=photo_url,
        swap_credits=swap_credits,
        swap_points=swap_points,
        total_swaps_completed=completed_swap_count,
        total_hours_traded=round(total_hours_traded, 1),
        average_rating=round(average_rating, 2),
        review_count=review_count,
        verified_skills_taught=verified_taught_list,
        verified_skills_learned=verified_learned_list,
        recent_swaps=recent_swaps,
        recent_reviews=recent_reviews,
        member_since=member_since,
    )


@router.get("/stats/{uid}")
def get_portfolio_stats(uid: str):
    """
    Get just the stats summary for a user (lightweight endpoint).
    """
    firebase = get_firebase_service()
    db = firebase.db

    profile_ref = db.collection("profiles").document(uid)
    profile_doc = profile_ref.get()

    if not profile_doc.exists:
        raise HTTPException(status_code=404, detail="User not found")

    profile = profile_doc.to_dict()

    return {
        "uid": uid,
        "swap_credits": profile.get("swap_credits", 0),
        "swap_points": profile.get("swap_points", 0),
        "completed_swap_count": profile.get("completed_swap_count", 0),
        "total_hours_traded": profile.get("total_hours_traded", 0.0),
        "average_rating": profile.get("average_rating", 0.0),
        "review_count": profile.get("review_count", 0),
    }
