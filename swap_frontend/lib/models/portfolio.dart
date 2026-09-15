/// Models for user skill portfolio.

import 'review.dart';

/// A verified skill from completed swaps.
class VerifiedSkill {
  final String skillName;
  final int timesExchanged;
  final double totalHours;
  final double averageRating;
  final DateTime? lastUsed;

  VerifiedSkill({
    required this.skillName,
    required this.timesExchanged,
    required this.totalHours,
    required this.averageRating,
    this.lastUsed,
  });

  factory VerifiedSkill.fromJson(Map<String, dynamic> json) => VerifiedSkill(
        skillName: json['skill_name'] as String? ?? '',
        timesExchanged: json['times_exchanged'] as int? ?? 0,
        totalHours: (json['total_hours'] as num?)?.toDouble() ?? 0.0,
        averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
        lastUsed: json['last_used'] != null
            ? DateTime.parse(json['last_used'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'skill_name': skillName,
        'times_exchanged': timesExchanged,
        'total_hours': totalHours,
        'average_rating': averageRating,
        'last_used': lastUsed?.toIso8601String(),
      };
}

/// Summary of a completed swap.
class CompletedSwapSummary {
  final String swapRequestId;
  final String partnerUid;
  final String? partnerName;
  final String? partnerPhoto;
  final String? skillTaught;
  final String? skillLearned;
  final double hoursExchanged;
  final int? ratingGiven;
  final int? ratingReceived;
  final DateTime completedAt;

  CompletedSwapSummary({
    required this.swapRequestId,
    required this.partnerUid,
    this.partnerName,
    this.partnerPhoto,
    this.skillTaught,
    this.skillLearned,
    required this.hoursExchanged,
    this.ratingGiven,
    this.ratingReceived,
    required this.completedAt,
  });

  factory CompletedSwapSummary.fromJson(Map<String, dynamic> json) =>
      CompletedSwapSummary(
        swapRequestId: json['swap_request_id'] as String? ?? '',
        partnerUid: json['partner_uid'] as String? ?? '',
        partnerName: json['partner_name'] as String?,
        partnerPhoto: json['partner_photo'] as String?,
        skillTaught: json['skill_taught'] as String?,
        skillLearned: json['skill_learned'] as String?,
        hoursExchanged: (json['hours_exchanged'] as num?)?.toDouble() ?? 0.0,
        ratingGiven: json['rating_given'] as int?,
        ratingReceived: json['rating_received'] as int?,
        completedAt: json['completed_at'] != null
            ? DateTime.parse(json['completed_at'] as String)
            : DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'swap_request_id': swapRequestId,
        'partner_uid': partnerUid,
        'partner_name': partnerName,
        'partner_photo': partnerPhoto,
        'skill_taught': skillTaught,
        'skill_learned': skillLearned,
        'hours_exchanged': hoursExchanged,
        'rating_given': ratingGiven,
        'rating_received': ratingReceived,
        'completed_at': completedAt.toIso8601String(),
      };
}

/// Full portfolio response for a user.
class PortfolioResponse {
  final String uid;
  final String? displayName;
  final String? photoUrl;
  final int swapCredits;
  final int swapPoints;
  final int totalSwapsCompleted;
  final double totalHoursTraded;
  final double averageRating;
  final int reviewCount;
  final List<VerifiedSkill> verifiedSkillsTaught;
  final List<VerifiedSkill> verifiedSkillsLearned;
  final List<CompletedSwapSummary> recentSwaps;
  final List<Review> recentReviews;
  final DateTime? memberSince;

  PortfolioResponse({
    required this.uid,
    this.displayName,
    this.photoUrl,
    required this.swapCredits,
    required this.swapPoints,
    required this.totalSwapsCompleted,
    required this.totalHoursTraded,
    required this.averageRating,
    required this.reviewCount,
    required this.verifiedSkillsTaught,
    required this.verifiedSkillsLearned,
    required this.recentSwaps,
    required this.recentReviews,
    this.memberSince,
  });

  factory PortfolioResponse.fromJson(Map<String, dynamic> json) =>
      PortfolioResponse(
        uid: json['uid'] as String? ?? '',
        displayName: json['display_name'] as String?,
        photoUrl: json['photo_url'] as String?,
        swapCredits: json['swap_credits'] as int? ?? 0,
        swapPoints: json['swap_points'] as int? ?? 0,
        totalSwapsCompleted: json['total_swaps_completed'] as int? ?? 0,
        totalHoursTraded:
            (json['total_hours_traded'] as num?)?.toDouble() ?? 0.0,
        averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
        reviewCount: json['review_count'] as int? ?? 0,
        verifiedSkillsTaught:
            (json['verified_skills_taught'] as List<dynamic>?)
                    ?.map((e) => VerifiedSkill.fromJson(e as Map<String, dynamic>))
                    .toList() ??
                [],
        verifiedSkillsLearned:
            (json['verified_skills_learned'] as List<dynamic>?)
                    ?.map((e) => VerifiedSkill.fromJson(e as Map<String, dynamic>))
                    .toList() ??
                [],
        recentSwaps: (json['recent_swaps'] as List<dynamic>?)
                ?.map((e) =>
                    CompletedSwapSummary.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        recentReviews: (json['recent_reviews'] as List<dynamic>?)
                ?.map((e) => Review.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        memberSince: json['member_since'] != null
            ? DateTime.parse(json['member_since'] as String)
            : null,
      );
}

/// Lightweight stats-only response.
class PortfolioStats {
  final String uid;
  final int swapCredits;
  final int swapPoints;
  final int completedSwapCount;
  final double totalHoursTraded;
  final double averageRating;
  final int reviewCount;

  PortfolioStats({
    required this.uid,
    required this.swapCredits,
    required this.swapPoints,
    required this.completedSwapCount,
    required this.totalHoursTraded,
    required this.averageRating,
    required this.reviewCount,
  });

  factory PortfolioStats.fromJson(Map<String, dynamic> json) => PortfolioStats(
        uid: json['uid'] as String? ?? '',
        swapCredits: json['swap_credits'] as int? ?? 0,
        swapPoints: json['swap_points'] as int? ?? 0,
        completedSwapCount: json['completed_swap_count'] as int? ?? 0,
        totalHoursTraded:
            (json['total_hours_traded'] as num?)?.toDouble() ?? 0.0,
        averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
        reviewCount: json['review_count'] as int? ?? 0,
      );
}
