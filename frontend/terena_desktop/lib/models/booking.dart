class Booking {
  int? id;
  String? bookingNumber;
  int? userId;
  String? userName;
  String? userEmail;
  int? venueId;
  String? venueName;
  String? venueLocation;
  String? venueAddress;
  String? venueContactPhone;
  double? venueAverageRating;
  int? venueTotalReviews;
  int? courtId;
  String? courtName;
  String? courtMaxCapacity;
  DateTime? bookingDate;
  DateTime? startTime;
  DateTime? endTime;
  double? duration;
  int? numberOfPlayers;
  bool? isGroupBooking;
  String? notes;
  double? pricePerHour;
  double? subtotalPrice;
  double? discountAmount;
  double? discountPercentage;
  double? serviceFee;
  double? totalPrice;
  DateTime? cancellationDeadline;
  String? status;
  DateTime? createdAt;
  DateTime? confirmedAt;
  DateTime? completedAt;
  DateTime? cancelledAt;
  String? cancellationReason;
  double? refundAmount;
  String? paymentMethod;
  String? paymentStatus;
  DateTime? paidAt;

  Booking({
    this.id,
    this.bookingNumber,
    this.userId,
    this.userName,
    this.userEmail,
    this.venueId,
    this.venueName,
    this.venueLocation,
    this.venueAddress,
    this.venueContactPhone,
    this.venueAverageRating,
    this.venueTotalReviews,
    this.courtId,
    this.courtName,
    this.courtMaxCapacity,
    this.bookingDate,
    this.startTime,
    this.endTime,
    this.duration,
    this.numberOfPlayers,
    this.isGroupBooking,
    this.notes,
    this.pricePerHour,
    this.subtotalPrice,
    this.discountAmount,
    this.discountPercentage,
    this.serviceFee,
    this.totalPrice,
    this.cancellationDeadline,
    this.status,
    this.createdAt,
    this.confirmedAt,
    this.completedAt,
    this.cancelledAt,
    this.cancellationReason,
    this.refundAmount,
    this.paymentMethod,
    this.paymentStatus,
    this.paidAt,
  });

  Booking.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    bookingNumber = json['bookingNumber'];
    userId = json['userId'];
    userName = json['userName'];
    userEmail = json['userEmail'];
    venueId = json['venueId'];
    venueName = json['venueName'];
    venueLocation = json['venueLocation'];
    venueAddress = json['venueAddress'];
    venueContactPhone = json['venueContactPhone'];
    venueAverageRating = json['venueAverageRating']?.toDouble();
    venueTotalReviews = json['venueTotalReviews'];
    courtId = json['courtId'];
    courtName = json['courtName'];
    courtMaxCapacity = json['courtMaxCapacity'];
    bookingDate =
        json['bookingDate'] != null
            ? DateTime.parse(json['bookingDate'])
            : null;
    startTime =
        json['startTime'] != null ? DateTime.parse(json['startTime']) : null;
    endTime = json['endTime'] != null ? DateTime.parse(json['endTime']) : null;
    duration = json['duration']?.toDouble();
    numberOfPlayers = json['numberOfPlayers'];
    isGroupBooking = json['isGroupBooking'];
    notes = json['notes'];
    pricePerHour = json['pricePerHour']?.toDouble();
    subtotalPrice = json['subtotalPrice']?.toDouble();
    discountAmount = json['discountAmount']?.toDouble();
    discountPercentage = json['discountPercentage']?.toDouble();
    serviceFee = json['serviceFee']?.toDouble();
    totalPrice = json['totalPrice']?.toDouble();
    cancellationDeadline =
        json['cancellationDeadline'] != null
            ? DateTime.parse(json['cancellationDeadline'])
            : null;
    if (json['status'] != null) {
      int statusValue =
          json['status'] is int
              ? json['status']
              : int.tryParse(json['status'].toString()) ?? 0;
      switch (statusValue) {
        case 0:
          status = 'Pending';
          break;
        case 1:
          status = 'Accepted';
          break;
        case 2:
          status = 'Confirmed';
          break;
        case 3:
          status = 'Completed';
          break;
        case 4:
          status = 'Cancelled';
          break;
        case 5:
          status = 'Expired';
          break;
        default:
          status = 'Pending';
      }
    }
    createdAt =
        json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null;
    confirmedAt =
        json['confirmedAt'] != null
            ? DateTime.parse(json['confirmedAt'])
            : null;
    completedAt =
        json['completedAt'] != null
            ? DateTime.parse(json['completedAt'])
            : null;
    cancelledAt =
        json['cancelledAt'] != null
            ? DateTime.parse(json['cancelledAt'])
            : null;
    cancellationReason = json['cancellationReason'];
    refundAmount = json['refundAmount']?.toDouble();
    paymentMethod = json['paymentMethod'];
    if (json['paymentStatus'] != null) {
      int paymentStatusValue =
          json['paymentStatus'] is int
              ? json['paymentStatus']
              : int.tryParse(json['paymentStatus'].toString()) ?? 0;
      switch (paymentStatusValue) {
        case 0:
          paymentStatus = 'Pending';
          break;
        case 1:
          paymentStatus = 'Paid';
          break;
        case 2:
          paymentStatus = 'Refunded';
          break;
        case 3:
          paymentStatus = 'PartiallyRefunded';
          break;
        default:
          paymentStatus = 'Pending';
      }
    }
    paidAt = json['paidAt'] != null ? DateTime.parse(json['paidAt']) : null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['bookingNumber'] = bookingNumber;
    data['userId'] = userId;
    data['userName'] = userName;
    data['userEmail'] = userEmail;
    data['venueId'] = venueId;
    data['venueName'] = venueName;
    data['venueLocation'] = venueLocation;
    data['venueAddress'] = venueAddress;
    data['venueContactPhone'] = venueContactPhone;
    data['venueAverageRating'] = venueAverageRating;
    data['venueTotalReviews'] = venueTotalReviews;
    data['courtId'] = courtId;
    data['courtName'] = courtName;
    data['courtMaxCapacity'] = courtMaxCapacity;
    data['bookingDate'] = bookingDate?.toIso8601String();
    data['startTime'] = startTime?.toIso8601String();
    data['endTime'] = endTime?.toIso8601String();
    data['duration'] = duration;
    data['numberOfPlayers'] = numberOfPlayers;
    data['isGroupBooking'] = isGroupBooking;
    data['notes'] = notes;
    data['pricePerHour'] = pricePerHour;
    data['subtotalPrice'] = subtotalPrice;
    data['discountAmount'] = discountAmount;
    data['discountPercentage'] = discountPercentage;
    data['serviceFee'] = serviceFee;
    data['totalPrice'] = totalPrice;
    data['cancellationDeadline'] = cancellationDeadline?.toIso8601String();
    data['status'] = status;
    data['createdAt'] = createdAt?.toIso8601String();
    data['confirmedAt'] = confirmedAt?.toIso8601String();
    data['completedAt'] = completedAt?.toIso8601String();
    data['cancelledAt'] = cancelledAt?.toIso8601String();
    data['cancellationReason'] = cancellationReason;
    data['refundAmount'] = refundAmount;
    data['paymentMethod'] = paymentMethod;
    data['paymentStatus'] = paymentStatus;
    data['paidAt'] = paidAt?.toIso8601String();
    return data;
  }
}
