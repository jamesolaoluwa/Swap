import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/portfolio.dart';

/// Service for portfolio API calls.
class PortfolioService {
  final String baseUrl;

  PortfolioService({String? baseUrl})
      : baseUrl = baseUrl ?? AppConfig.apiBaseUrl;

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

  /// Get full portfolio for a user.
  Future<PortfolioResponse> getPortfolio(
    String uid, {
    bool includeSwaps = true,
    bool includeReviews = true,
    int swapLimit = 10,
    int reviewLimit = 5,
  }) async {
    final uri = Uri.parse('$baseUrl/portfolio/user/$uid').replace(
      queryParameters: {
        'include_swaps': includeSwaps.toString(),
        'include_reviews': includeReviews.toString(),
        'swap_limit': swapLimit.toString(),
        'review_limit': reviewLimit.toString(),
      },
    );

    debugPrint('PortfolioService: GET $uri');

    final headers = await _getHeaders();
    final response = await http.get(uri, headers: headers).timeout(
          const Duration(seconds: 15),
        );

    if (response.statusCode != 200) {
      throw Exception(
          'Failed to get portfolio: ${response.statusCode} ${response.reasonPhrase}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return PortfolioResponse.fromJson(data);
  }

  /// Get lightweight stats only for a user.
  Future<PortfolioStats> getStats(String uid) async {
    final uri = Uri.parse('$baseUrl/portfolio/stats/$uid');

    debugPrint('PortfolioService: GET $uri');

    final headers = await _getHeaders();
    final response = await http.get(uri, headers: headers).timeout(
          const Duration(seconds: 15),
        );

    if (response.statusCode != 200) {
      throw Exception(
          'Failed to get portfolio stats: ${response.statusCode} ${response.reasonPhrase}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return PortfolioStats.fromJson(data);
  }
}
