import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/venue.dart';
import '../utils/config.dart';

class RecommendationProvider {
  static String get baseUrl => Config.apiBaseUrl;

  Future<List<Venue>> getRecommendations(int userId, {int count = 10}) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/Recommendation/GetRecommendations/$userId?count=$count',
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Venue.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}
