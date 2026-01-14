import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:terena_admin/utils/config.dart';

class StatisticsProvider {
  static String get _baseUrl => '${Config.apiBaseUrl}/Statistics';

  Map<String, String> createHeaders() {
    return {"Content-Type": "application/json"};
  }

  bool isValidResponse(http.Response response) {
    return response.statusCode >= 200 && response.statusCode < 300;
  }

  Future<Map<String, dynamic>> getEarnings({
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    var url = "$_baseUrl/earnings";
    var params = <String, String>{};

    if (fromDate != null) {
      params['fromDate'] = fromDate.toIso8601String();
    }
    if (toDate != null) {
      params['toDate'] = toDate.toIso8601String();
    }

    var uri = Uri.parse(url).replace(queryParameters: params);
    var headers = createHeaders();
    var response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load earnings data');
    }
  }

  Future<Map<String, dynamic>> getWeeklyEarnings() async {
    var url = "$_baseUrl/weekly-earnings";
    var uri = Uri.parse(url);
    var headers = createHeaders();
    var response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load weekly earnings');
    }
  }

  Future<Map<String, dynamic>> getBookingStatus({
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    var url = "$_baseUrl/booking-status";
    var params = <String, String>{};

    if (fromDate != null) {
      params['fromDate'] = fromDate.toIso8601String();
    }
    if (toDate != null) {
      params['toDate'] = toDate.toIso8601String();
    }

    var uri = Uri.parse(url).replace(queryParameters: params);
    var headers = createHeaders();
    var response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load booking status');
    }
  }

  Future<Map<String, dynamic>> getTopVenues({int count = 10}) async {
    var url = "$_baseUrl/top-venues";
    var uri = Uri.parse(
      url,
    ).replace(queryParameters: {'count': count.toString()});
    var headers = createHeaders();
    var response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load top venues');
    }
  }

  Future<int> getActiveVenues() async {
    var url = "$_baseUrl/active-venues";
    var uri = Uri.parse(url);
    var headers = createHeaders();
    var response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load active venues count');
    }
  }
}
