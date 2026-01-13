import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:terena_admin/models/user.dart';
import 'package:terena_admin/providers/base_provider.dart';
import 'package:terena_admin/providers/helper_providers/auth_provider.dart';

class UserProvider extends BaseProvider<User> {
  static const String baseUrl = "http://localhost:5152/api";

  UserProvider() : super("User");

  @override
  User fromJson(data) {
    return User.fromJson(data);
  }

  Future<User> login(String username, String password) async {
    var url = "$baseUrl/User/login";
    var uri = Uri.parse(url);

    Map<String, String> headers = {"Content-Type": "application/json"};

    var body = jsonEncode({"username": username, "password": password});

    var response = await http.post(uri, headers: headers, body: body);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);

      if (data['role'] != 0) {
        throw Exception('Access denied. Admin privileges required.');
      }

      AuthProvider.username = username;
      AuthProvider.password = password;
      AuthProvider.userId = data['id'];
      AuthProvider.isAdmin = true;
      return fromJson(data);
    } else {
      try {
        var errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'An error occurred');
      } catch (e) {
        if (e is Exception && e.toString().contains('Exception:')) {
          rethrow;
        }
        throw Exception('An error occurred');
      }
    }
  }

  Future<User> blockUser(int id, String reason) async {
    var url = "$baseUrl/User/$id/block";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var jsonRequest = jsonEncode({"reason": reason});
    var response = await http.post(uri, headers: headers, body: jsonRequest);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      try {
        var errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'An error occurred');
      } catch (e) {
        if (e is Exception && e.toString().contains('Exception:')) {
          rethrow;
        }
        throw Exception('An error occurred');
      }
    }
  }

  Future<User> unblockUser(int id) async {
    var url = "$baseUrl/User/$id/unblock";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.post(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      try {
        var errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'An error occurred');
      } catch (e) {
        if (e is Exception && e.toString().contains('Exception:')) {
          rethrow;
        }
        throw Exception('An error occurred');
      }
    }
  }

  void logout() {
    AuthProvider.username = null;
    AuthProvider.password = null;
    AuthProvider.userId = null;
    AuthProvider.isAdmin = false;
  }
}
