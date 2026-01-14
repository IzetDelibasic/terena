import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/review.dart';
import '../utils/config.dart';

class ReviewProvider {
  String get baseUrl => '${Config.apiBaseUrl}/Review';

  Future<List<Review>> getReviews({int? venueId, int? userId}) async {
    try {
      var url = baseUrl;
      final queryParams = <String>[];

      if (venueId != null) {
        queryParams.add('venueId=$venueId');
      }
      if (userId != null) {
        queryParams.add('userId=$userId');
      }

      if (queryParams.isNotEmpty) {
        url += '?${queryParams.join('&')}';
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final reviews =
            (data['resultList'] as List)
                .map((json) => Review.fromJson(json))
                .toList();
        return reviews;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<bool> createReview({
    required int userId,
    required int venueId,
    required int rating,
    String? comment,
    int? bookingId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': userId,
          'venueId': venueId,
          'rating': rating,
          'comment': comment,
          'bookingId': bookingId,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateReview({
    required int id,
    required int rating,
    String? comment,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'rating': rating, 'comment': comment}),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteReview(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$id'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
