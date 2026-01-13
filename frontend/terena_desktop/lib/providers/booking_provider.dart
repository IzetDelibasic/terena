import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:terena_admin/models/booking.dart';
import 'package:terena_admin/models/search_result.dart';
import 'package:terena_admin/providers/base_provider.dart';

class BookingProvider extends BaseProvider<Booking> {
  BookingProvider() : super("Booking");

  @override
  Booking fromJson(data) {
    return Booking.fromJson(data);
  }

  @override
  Future<SearchResult<Booking>> get({Map<String, dynamic>? filter}) async {
    var url = "http://localhost:5152/api/Booking/admin/all";

    if (filter != null) {
      var queryString = getQueryString(filter);
      url = "$url?$queryString";
    }

    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return SearchResult<Booking>.fromJson(data, fromJson);
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

  Future<Booking> approveBooking(int bookingId) async {
    var url = "http://localhost:5152/api/Booking/$bookingId/admin/confirm";
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

  Future<Booking> rejectBooking(int bookingId, String reason) async {
    var url = "http://localhost:5152/api/Booking/$bookingId/admin/reject";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var body = jsonEncode({"cancellationReason": reason});
    var response = await http.post(uri, headers: headers, body: body);

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

  Future<Booking> cancelBooking(int bookingId, String reason) async {
    var url = "http://localhost:5152/api/Booking/$bookingId/cancel";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var body = jsonEncode({"cancellationReason": reason});
    var response = await http.post(uri, headers: headers, body: body);

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

  Future<Booking> refundBooking(int bookingId, {double? refundAmount}) async {
    var url = "http://localhost:5152/api/Booking/$bookingId/refund";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var body = jsonEncode({"refundAmount": refundAmount});
    var response = await http.post(uri, headers: headers, body: body);

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
}
