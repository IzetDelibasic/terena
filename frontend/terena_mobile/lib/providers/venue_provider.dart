import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/venue.dart';

class VenueProvider {
  static const String baseUrl = "http://10.0.2.2:5152/api";

  Future<List<Venue>> getVenues({String? sportType}) async {
    try {
      var url = "$baseUrl/Venue";
      if (sportType != null) {
        url += "?sportType=$sportType";
      }

      var uri = Uri.parse(url);
      var response = await http.get(uri);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        List<dynamic> venueList;
        if (data is Map && data.containsKey('resultList')) {
          venueList = data['resultList'];
        } else if (data is Map && data.containsKey('result')) {
          venueList = data['result'];
        } else if (data is List) {
          venueList = data;
        } else {
          return [];
        }

        return venueList.map((json) => Venue.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Venue?> getVenueById(int id) async {
    try {
      var url = "$baseUrl/Venue/$id";
      var uri = Uri.parse(url);
      var response = await http.get(uri);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        return Venue.fromJson(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  List<Venue> getMockVenues() {
    return [
      Venue(
        id: 1,
        name: "Stadium Alpha",
        address: "Zmaja od Bosne bb",
        location: "Sarajevo",
        pricePerHour: 45.0,
        rating: 4.8,
        reviewCount: 92,
        sportType: "Football",
        hasParking: true,
        hasShowers: true,
        hasLighting: true,
        hasChangingRooms: true,
      ),
      Venue(
        id: 2,
        name: "Elite Padel Club",
        address: "Centar",
        location: "Banja Luka",
        pricePerHour: 50.0,
        rating: 4.9,
        reviewCount: 167,
        sportType: "Padel",
        hasParking: true,
        hasLighting: true,
      ),
      Venue(
        id: 3,
        name: "Skyline Court",
        address: "Centar",
        location: "Mostar",
        pricePerHour: 35.0,
        rating: 4.7,
        reviewCount: 203,
        sportType: "Basketball",
        hasShowers: true,
        hasLighting: true,
      ),
      Venue(
        id: 4,
        name: "Beach Volley Paradise",
        address: "Beach Road",
        location: "Neum",
        pricePerHour: 30.0,
        rating: 4.9,
        reviewCount: 89,
        sportType: "Volleyball",
      ),
      Venue(
        id: 5,
        name: "Central 5-a-Side",
        address: "Centar",
        location: "Sarajevo",
        pricePerHour: 40.0,
        rating: 4.7,
        reviewCount: 203,
        sportType: "Mini Football",
        hasParking: true,
      ),
      Venue(
        id: 6,
        name: "Grand Slam Tennis",
        address: "Sports Complex",
        location: "Sarajevo",
        pricePerHour: 25.0,
        rating: 4.6,
        reviewCount: 156,
        sportType: "Tennis",
        hasChangingRooms: true,
      ),
    ];
  }
}
