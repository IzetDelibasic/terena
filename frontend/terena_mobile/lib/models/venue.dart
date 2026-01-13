class Venue {
  final int id;
  final String name;
  final String? location;
  final String? address;
  final String? imageUrl;
  final double? pricePerHour;
  final double? rating;
  final int? reviewCount;
  final String? sportType;
  final String? surfaceType;
  final String? description;
  final bool hasParking;
  final bool hasShowers;
  final bool hasLighting;
  final bool hasChangingRooms;
  final bool hasEquipmentRental;
  final bool hasCafeBar;
  final Discount? discount;
  final CancellationPolicy? cancellationPolicy;

  Venue({
    required this.id,
    required this.name,
    this.location,
    this.address,
    this.imageUrl,
    this.pricePerHour,
    this.rating,
    this.reviewCount,
    this.sportType,
    this.surfaceType,
    this.description,
    this.hasParking = false,
    this.hasShowers = false,
    this.hasLighting = false,
    this.hasChangingRooms = false,
    this.hasEquipmentRental = false,
    this.hasCafeBar = false,
    this.discount,
    this.cancellationPolicy,
  });

  factory Venue.fromJson(Map<String, dynamic> json) {
    return Venue(
      id: json['id'],
      name: json['name'] ?? '',
      location: json['location'],
      address: json['address'],
      imageUrl: json['venueImageUrl'],
      pricePerHour: json['pricePerHour']?.toDouble(),
      rating: json['averageRating']?.toDouble(),
      reviewCount: json['totalReviews'],
      sportType: json['sportType'],
      surfaceType: json['surfaceType'],
      description: json['description'],
      hasParking: json['hasParking'] ?? false,
      hasShowers: json['hasShowers'] ?? false,
      hasLighting: json['hasLighting'] ?? false,
      hasChangingRooms: json['hasChangingRooms'] ?? false,
      hasEquipmentRental: json['hasEquipmentRental'] ?? false,
      hasCafeBar: json['hasCafeBar'] ?? false,
      discount:
          json['discount'] != null ? Discount.fromJson(json['discount']) : null,
      cancellationPolicy:
          json['cancellationPolicy'] != null
              ? CancellationPolicy.fromJson(json['cancellationPolicy'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'address': address,
      'venueImageUrl': imageUrl,
      'pricePerHour': pricePerHour,
      'averageRating': rating,
      'totalReviews': reviewCount,
      'sportType': sportType,
      'surfaceType': surfaceType,
      'description': description,
      'hasParking': hasParking,
      'hasShowers': hasShowers,
      'hasLighting': hasLighting,
      'hasChangingRooms': hasChangingRooms,
      'hasEquipmentRental': hasEquipmentRental,
      'hasCafeBar': hasCafeBar,
      'discount': discount?.toJson(),
      'cancellationPolicy': cancellationPolicy?.toJson(),
    };
  }

  String? get venueImageUrl => imageUrl;
}

class Discount {
  final double? percentage;
  final int? forBookings;

  Discount({this.percentage, this.forBookings});

  factory Discount.fromJson(Map<String, dynamic> json) {
    return Discount(
      percentage: json['percentage']?.toDouble(),
      forBookings: json['forBookings'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'percentage': percentage, 'forBookings': forBookings};
  }
}

class CancellationPolicy {
  final DateTime? freeUntil;
  final double? fee;

  CancellationPolicy({this.freeUntil, this.fee});

  factory CancellationPolicy.fromJson(Map<String, dynamic> json) {
    return CancellationPolicy(
      freeUntil:
          json['freeUntil'] != null ? DateTime.parse(json['freeUntil']) : null,
      fee: json['fee']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'freeUntil': freeUntil?.toIso8601String(), 'fee': fee};
  }
}
