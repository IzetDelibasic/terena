import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/booking.dart';

class BookingProvider {
  static const String baseUrl = "http://10.0.2.2:5152/api";

  Future<Map<String, dynamic>?> createPaymentIntent(
    double amount,
    String description,
  ) async {
    try {
      var url = "$baseUrl/Booking/create-payment-intent";
      var uri = Uri.parse(url);

      Map<String, String> headers = {"Content-Type": "application/json"};
      var body = jsonEncode({"amount": amount, "description": description});

      var response = await http.post(uri, headers: headers, body: body);

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        return responseData;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<List<Booking>> getBookings(int userId) async {
    try {
      var url = "$baseUrl/Booking?UserId=$userId";
      var uri = Uri.parse(url);
      var response = await http.get(uri);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        List<dynamic> bookingList;
        if (data is Map && data.containsKey('resultList')) {
          bookingList = data['resultList'];
        } else if (data is List) {
          bookingList = data;
        } else {
          return [];
        }

        return bookingList.map((json) => Booking.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<String>> getAvailableTimeSlots(int venueId, DateTime date) async {
    try {
      final dateStr = date.toIso8601String();
      var url =
          "$baseUrl/Booking/available-slots?venueId=$venueId&date=$dateStr";
      var uri = Uri.parse(url);
      var response = await http.get(uri);

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((slot) => slot.toString()).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<int> getMaxDurationForSlot(
    int venueId,
    DateTime date,
    String timeSlot,
  ) async {
    try {
      final dateStr = date.toIso8601String();
      var url =
          "$baseUrl/Booking/max-duration?venueId=$venueId&date=$dateStr&timeSlot=$timeSlot";
      var uri = Uri.parse(url);
      var response = await http.get(uri);

      if (response.statusCode == 200) {
        return int.parse(response.body);
      }
      return 1;
    } catch (e) {
      return 1;
    }
  }

  Future<Booking?> createBooking({
    required int userId,
    required int venueId,
    required DateTime bookingDate,
    required DateTime startTime,
    required DateTime endTime,
    required double pricePerHour,
    int numberOfPlayers = 1,
    String? notes,
    String paymentMethod = 'Cash',
    String? stripePaymentIntentId,
  }) async {
    try {
      var url = "$baseUrl/Booking";
      var uri = Uri.parse(url);

      Map<String, String> headers = {"Content-Type": "application/json"};

      var body = jsonEncode({
        "userId": userId,
        "venueId": venueId,
        "bookingDate": bookingDate.toIso8601String(),
        "startTime": startTime.toIso8601String(),
        "endTime": endTime.toIso8601String(),
        "pricePerHour": pricePerHour,
        "numberOfPlayers": numberOfPlayers,
        "isGroupBooking": numberOfPlayers > 1,
        "notes": notes,
        "paymentMethod": paymentMethod,
        "stripePaymentIntentId": stripePaymentIntentId,
      });

      var response = await http.post(uri, headers: headers, body: body);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        return Booking.fromJson(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> cancelBooking(int bookingId, String reason) async {
    try {
      var url = "$baseUrl/Booking/$bookingId/cancel";
      var uri = Uri.parse(url);

      Map<String, String> headers = {"Content-Type": "application/json"};
      var body = jsonEncode({"cancellationReason": reason});

      var response = await http.post(uri, headers: headers, body: body);

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
