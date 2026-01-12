import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/venue.dart';

class FavoriteProvider extends ChangeNotifier {
  static const String baseUrl = "http://10.0.2.2:5152/api";

  List<Venue> _favorites = [];
  bool _isLoading = false;

  List<Venue> get favorites => _favorites;
  bool get isLoading => _isLoading;

  Future<List<Venue>> getUserFavorites(int userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      var url = "$baseUrl/Favorite/user/$userId";
      var uri = Uri.parse(url);
      var response = await http.get(uri);

      print('Get favorites - Status: ${response.statusCode}');
      print('Get favorites - Body: ${response.body}');

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        _favorites = data.map((json) => Venue.fromJson(json['venue'])).toList();
        _isLoading = false;
        notifyListeners();
        return _favorites;
      }
      _isLoading = false;
      notifyListeners();
      return [];
    } catch (e) {
      print('Error fetching favorites: $e');
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  Future<bool> addFavorite(int userId, int venueId) async {
    try {
      var url = "$baseUrl/Favorite";
      var uri = Uri.parse(url);

      Map<String, String> headers = {"Content-Type": "application/json"};
      var body = jsonEncode({"userId": userId, "venueId": venueId});

      print('Add favorite - URL: $url');
      print('Add favorite - Body: $body');

      var response = await http.post(uri, headers: headers, body: body);

      print('Add favorite - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        await getUserFavorites(userId);
        return true;
      }
      return false;
    } catch (e) {
      print('Error adding favorite: $e');
      return false;
    }
  }

  Future<bool> removeFavorite(int userId, int venueId) async {
    try {
      var url = "$baseUrl/Favorite/user/$userId/venue/$venueId";
      var uri = Uri.parse(url);

      print('Remove favorite - URL: $url');

      var response = await http.delete(uri);

      print('Remove favorite - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        await getUserFavorites(userId);
        return true;
      }
      return false;
    } catch (e) {
      print('Error removing favorite: $e');
      return false;
    }
  }

  Future<bool> isFavorite(int userId, int venueId) async {
    try {
      var url = "$baseUrl/Favorite/user/$userId/venue/$venueId/check";
      var uri = Uri.parse(url);
      var response = await http.get(uri);

      if (response.statusCode == 200) {
        return jsonDecode(response.body) == true;
      }
      return false;
    } catch (e) {
      print('Error checking favorite: $e');
      return false;
    }
  }
}
