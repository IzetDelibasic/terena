import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  static const String baseUrl = "http://10.0.2.2:5152/api";
  User? _currentUser;
  String? _token;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  String? _lastError;
  String? get lastError => _lastError;

  Future<bool> login(String username, String password) async {
    try {
      _lastError = null;
      var url = "$baseUrl/User/login";
      var uri = Uri.parse(url);

      Map<String, String> headers = {"Content-Type": "application/json"};
      var body = jsonEncode({"username": username, "password": password});

      print('Login attempt - URL: $url');
      print('Login attempt - Username: $username');
      print('Login attempt - Body: $body');

      var response = await http.post(uri, headers: headers, body: body);

      print('Login response - Status: ${response.statusCode}');
      print('Login response - Body: ${response.body}');

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        _currentUser = User.fromJson(data);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', jsonEncode(data));
        await prefs.setString('username', username);
        await prefs.setString('password', password);

        return true;
      } else {
        try {
          var errorData = jsonDecode(response.body);

          if (errorData['message'] != null) {
            _lastError = errorData['message'];
          } else if (errorData['errors'] != null &&
              errorData['errors']['generalException'] != null) {
            _lastError = errorData['errors']['generalException'][0];
          } else if (errorData['errors'] != null &&
              errorData['errors']['userException'] != null) {
            _lastError = errorData['errors']['userException'][0];
          } else {
            _lastError = 'Invalid username or password';
          }
        } catch (e) {
          print('Error parsing response: $e');
          _lastError = 'Invalid username or password';
        }
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      _lastError = 'Network error. Please try again.';
      return false;
    }
  }

  Future<bool> register({
    required String username,
    required String password,
    required String email,
    String? phoneNumber,
    String? country,
    String? address,
  }) async {
    try {
      var url = "$baseUrl/User/register";
      var uri = Uri.parse(url);

      Map<String, String> headers = {"Content-Type": "application/json"};
      var body = jsonEncode({
        "username": username,
        "password": password,
        "email": email,
        "phoneNumber": phoneNumber,
        "country": country,
        "address": address,
        "role": 1,
      });

      var response = await http.post(uri, headers: headers, body: body);

      if (response.statusCode == 200) {
        return await login(username, password);
      }
      return false;
    } catch (e) {
      print('Registration error: $e');
      return false;
    }
  }

  Future<bool> updateProfile({
    required int userId,
    String? username,
    String? email,
    String? phone,
  }) async {
    try {
      var url = "$baseUrl/User/$userId";
      var uri = Uri.parse(url);

      Map<String, String> headers = {"Content-Type": "application/json"};
      var body = jsonEncode({
        "username": username,
        "email": email,
        "phone": phone,
      });

      print('Update profile - URL: $url');
      print('Update profile - Body: $body');

      var response = await http.put(uri, headers: headers, body: body);

      print('Update response - Status: ${response.statusCode}');
      print('Update response - Body: ${response.body}');

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        _currentUser = User.fromJson(data);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', jsonEncode(data));

        return true;
      }
      return false;
    } catch (e) {
      print('Update profile error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    _token = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    await prefs.remove('username');
    await prefs.remove('password');
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('username') || !prefs.containsKey('password')) {
      return false;
    }

    final username = prefs.getString('username');
    final password = prefs.getString('password');

    if (username != null && password != null) {
      return await login(username, password);
    }

    return false;
  }
}
