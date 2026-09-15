/// Models for reviews.

/// A review for a completed swap.
class Review {
  final String id;
  final String swapRequestId;
  final String reviewerUid;
  final String reviewedUid;
  final int rating;
  final String? reviewText;
  final String? skillExchanged;
  final double? hoursExchanged;
  final DateTime createdAt;
  final String? reviewerName;
  final String? reviewerPhoto;

  Review({
    required this.id,
    required this.swapRequestId,
    required this.reviewerUid,
    required this.reviewedUid,
    required this.rating,
    this.reviewText,
    this.skillExchanged,
    this.hoursExchanged,
    required this.createdAt,
    this.reviewerName,
    this.reviewerPhoto,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        id: json['id'] as String? ?? '',
        swapRequestId: json['swap_request_id'] as String? ?? '',
        reviewerUid: json['reviewer_uid'] as String? ?? '',
        reviewedUid: json['reviewed_uid'] as String? ?? '',
        rating: json['rating'] as int? ?? 0,
        reviewText: json['review_text'] as String?,
        skillExchanged: json['skill_exchanged'] as String?,
        hoursExchanged: (json['hours_exchanged'] as num?)?.toDouble(),
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : DateTime.now(),
        reviewerName: json['reviewer_name'] as String?,
        reviewerPhoto: json['reviewer_photo'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'swap_request_id': swapRequestId,
        'reviewer_uid': reviewerUid,
        'reviewed_uid': reviewedUid,
        'rating': rating,
        'review_text': reviewText,
        'skill_exchanged': skillExchanged,
        'hours_exchanged': hoursExchanged,
        'created_at': createdAt.toIso8601String(),
        'reviewer_name': reviewerName,
        'reviewer_photo': reviewerPhoto,
      };
}

/// Response containing a list of reviews.
class ReviewListResponse {
  final List<Review> reviews;
  final int total;
  final double averageRating;

  ReviewListResponse({
    required this.reviews,
    required this.total,
    required this.averageRating,
  });

  factory ReviewListResponse.fromJson(Map<String, dynamic> json) =>
      ReviewListResponse(
        reviews: (json['reviews'] as List<dynamic>?)
                ?.map((e) => Review.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        total: json['total'] as int? ?? 0,
        averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      );
}
