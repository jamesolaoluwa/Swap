import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/review.dart';

/// Service for review API calls.
class ReviewService {
  final String baseUrl;

  ReviewService({String? baseUrl}) : baseUrl = baseUrl ?? AppConfig.apiBaseUrl;

  /// Get authorization headers if user is signed in.
  Future<Map<String, String>> _getHeaders() async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && !kIsWeb) {
        final idToken = await user.getIdToken();
        if (idToken != null) {
          headers['Authorization'] = 'Bearer $idToken';
        }
      }
    } catch (_) {
      // Ignore token errors
    }

    return headers;
  }

  /// Submit a review for a completed swap.
  Future<Review> submitReview({
    required String uid,
    required String swapRequestId,
    required int rating,
    String? reviewText,
  }) async {
    final uri = Uri.parse('$baseUrl/reviews')
        .replace(queryParameters: {'uid': uid});

    debugPrint('ReviewService: POST $uri');

    final headers = await _getHeaders();
    final body = jsonEncode({
      'swap_request_id': swapRequestId,
      'rating': rating,
      if (reviewText != null && reviewText.isNotEmpty) 'review_text': reviewText,
    });

    final response = await http
        .post(uri, headers: headers, body: body)
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      final errorBody = response.body;
      throw Exception(
          'Failed to submit review: ${response.statusCode} $errorBody');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return Review.fromJson(data);
  }

  /// Get reviews received by a user.
  Future<ReviewListResponse> getUserReviews(
    String uid, {
    int limit = 20,
    int offset = 0,
  }) async {
    final uri = Uri.parse('$baseUrl/reviews/user/$uid').replace(
      queryParameters: {
        'limit': limit.toString(),
        'offset': offset.toString(),
      },
    );

    debugPrint('ReviewService: GET $uri');

    final headers = await _getHeaders();
    final response = await http.get(uri, headers: headers).timeout(
          const Duration(seconds: 15),
        );

    if (response.statusCode != 200) {
      throw Exception(
          'Failed to get user reviews: ${response.statusCode} ${response.reasonPhrase}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return ReviewListResponse.fromJson(data);
  }

  /// Get reviews given by a user.
  Future<ReviewListResponse> getReviewsGiven(
    String uid, {
    int limit = 20,
    int offset = 0,
  }) async {
    final uri = Uri.parse('$baseUrl/reviews/given/$uid').replace(
      queryParameters: {
        'limit': limit.toString(),
        'offset': offset.toString(),
      },
    );

    debugPrint('ReviewService: GET $uri');

    final headers = await _getHeaders();
    final response = await http.get(uri, headers: headers).timeout(
          const Duration(seconds: 15),
        );

    if (response.statusCode != 200) {
      throw Exception(
          'Failed to get reviews given: ${response.statusCode} ${response.reasonPhrase}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return ReviewListResponse.fromJson(data);
  }

  /// Get reviews for a specific swap.
  Future<Map<String, dynamic>> getSwapReviews(
      String swapRequestId, String uid) async {
    final uri = Uri.parse('$baseUrl/reviews/swap/$swapRequestId')
        .replace(queryParameters: {'uid': uid});

    debugPrint('ReviewService: GET $uri');

    final headers = await _getHeaders();
    final response = await http.get(uri, headers: headers).timeout(
          const Duration(seconds: 15),
        );

    if (response.statusCode != 200) {
      throw Exception(
          'Failed to get swap reviews: ${response.statusCode} ${response.reasonPhrase}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return {
      'swap_request_id': data['swap_request_id'],
      'reviews': (data['reviews'] as List<dynamic>?)
              ?.map((e) => Review.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      'user_has_reviewed': data['user_has_reviewed'] as bool? ?? false,
      'can_review': data['can_review'] as bool? ?? false,
    };
  }
}
