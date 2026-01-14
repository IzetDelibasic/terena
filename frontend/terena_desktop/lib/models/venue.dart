class Venue {
  int? id;
  String? name;
  String? location;
  String? address;
  String? sportType;
  String? surfaceType;
  double? pricePerHour;
  int? availableSlots;
  String? description;
  String? contactPhone;
  String? contactEmail;
  String? venueImageUrl;
  double? averageRating;
  int? totalReviews;
  List<String>? amenities;
  List<OperatingHour>? operatingHours;
  CancellationPolicy? cancellationPolicy;
  Discount? discount;

  Venue({
    this.id,
    this.name,
    this.location,
    this.address,
    this.sportType,
    this.surfaceType,
    this.pricePerHour,
    this.availableSlots,
    this.description,
    this.contactPhone,
    this.contactEmail,
    this.venueImageUrl,
    this.averageRating,
    this.totalReviews,
    this.amenities,
    this.operatingHours,
    this.cancellationPolicy,
    this.discount,
  });

  Venue.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    location = json['location'];
    address = json['address'];
    sportType = json['sportType'];
    surfaceType = json['surfaceType'];
    pricePerHour = json['pricePerHour']?.toDouble();
    availableSlots = json['availableSlots'];
    description = json['description'];
    contactPhone = json['contactPhone'];
    contactEmail = json['contactEmail'];
    venueImageUrl = json['venueImageUrl'];
    averageRating = json['averageRating']?.toDouble();
    totalReviews = json['totalReviews'];

    if (json['amenities'] != null) {
      amenities = List<String>.from(json['amenities']);
    }

    if (json['operatingHours'] != null) {
      operatingHours = <OperatingHour>[];
      json['operatingHours'].forEach((v) {
        operatingHours!.add(OperatingHour.fromJson(v));
      });
    }

    cancellationPolicy =
        json['cancellationPolicy'] != null
            ? CancellationPolicy.fromJson(json['cancellationPolicy'])
            : null;

    discount =
        json['discount'] != null ? Discount.fromJson(json['discount']) : null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['location'] = location;
    data['address'] = address;
    data['sportType'] = sportType;
    data['surfaceType'] = surfaceType;
    data['pricePerHour'] = pricePerHour;
    data['availableSlots'] = availableSlots;
    data['description'] = description;
    data['contactPhone'] = contactPhone;
    data['contactEmail'] = contactEmail;
    data['venueImageUrl'] = venueImageUrl;
    data['averageRating'] = averageRating;
    data['totalReviews'] = totalReviews;
    data['amenities'] = amenities;
    if (operatingHours != null) {
      data['operatingHours'] = operatingHours!.map((v) => v.toJson()).toList();
    }
    if (cancellationPolicy != null) {
      data['cancellationPolicy'] = cancellationPolicy!.toJson();
    }
    if (discount != null) {
      data['discount'] = discount!.toJson();
    }
    return data;
  }

  bool get hasParking => amenities?.contains('Parking') ?? false;
  bool get hasShowers => amenities?.contains('Showers') ?? false;
  bool get hasLighting => amenities?.contains('Lighting') ?? false;
  bool get hasChangingRooms => amenities?.contains('Restrooms') ?? false;
  bool get hasEquipmentRental => amenities?.contains('WiFi') ?? false;
  bool get hasCafeBar => amenities?.contains('CCTV') ?? false;
  bool get hasWaterFountain => amenities?.contains('Water Fountain') ?? false;
  bool get hasSeatingArea => amenities?.contains('Seating Area') ?? false;
}

class OperatingHour {
  String? day;
  String? startTime;
  String? endTime;

  OperatingHour({this.day, this.startTime, this.endTime});

  OperatingHour.fromJson(Map<String, dynamic> json) {
    day = json['day'];
    startTime = json['startTime'];
    endTime = json['endTime'];
  }

  Map<String, dynamic> toJson() {
    return {'day': day, 'startTime': startTime, 'endTime': endTime};
  }
}

class CancellationPolicy {
  double? fee;

  CancellationPolicy({this.fee});

  CancellationPolicy.fromJson(Map<String, dynamic> json) {
    fee = json['fee']?.toDouble();
  }

  Map<String, dynamic> toJson() {
    return {'fee': fee};
  }
}

class Discount {
  double? percentage;
  int? forBookings;

  Discount({this.percentage, this.forBookings});

  Discount.fromJson(Map<String, dynamic> json) {
    percentage = json['percentage']?.toDouble();
    forBookings = json['forBookings'];
  }

  Map<String, dynamic> toJson() {
    return {'percentage': percentage, 'forBookings': forBookings};
  }
}
