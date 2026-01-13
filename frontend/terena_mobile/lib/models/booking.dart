class Booking {
  final int id;
  final String bookingNumber;
  final int userId;
  final String? userName;
  final int venueId;
  final String venueName;
  final String? venueLocation;
  final String? location;
  final DateTime bookingDate;
  final DateTime startTime;
  final DateTime endTime;
  final double duration;
  final double pricePerHour;
  final double totalPrice;
  final double? discountAmount;
  final double? discountPercentage;
  final String status;
  final String paymentStatus;
  final String? courtName;
  final int? courtId;
  final String? notes;
  final String? venueImageUrl;

  Booking({
    required this.id,
    required this.bookingNumber,
    required this.userId,
    this.userName,
    required this.venueId,
    required this.venueName,
    this.venueLocation,
    this.location,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.pricePerHour,
    required this.totalPrice,
    this.discountAmount,
    this.discountPercentage,
    required this.status,
    required this.paymentStatus,
    this.courtName,
    this.courtId,
    this.notes,
    this.venueImageUrl,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    String mapStatus(dynamic status) {
      if (status == null) return 'Pending';

      final statusValue =
          status is int ? status : int.tryParse(status.toString());

      switch (statusValue) {
        case 0:
          return 'Pending';
        case 1:
          return 'Accepted';
        case 2:
          return 'Confirmed';
        case 3:
          return 'Completed';
        case 4:
          return 'Cancelled';
        case 5:
          return 'Expired';
        default:
          return status.toString();
      }
    }

    String mapPaymentStatus(dynamic paymentStatus) {
      if (paymentStatus == null) return 'Pending';

      final statusValue =
          paymentStatus is int
              ? paymentStatus
              : int.tryParse(paymentStatus.toString());

      switch (statusValue) {
        case 0:
          return 'Pending';
        case 1:
          return 'Paid';
        case 2:
          return 'Failed';
        case 3:
          return 'Refunded';
        default:
          return paymentStatus.toString();
      }
    }

    return Booking(
      id: json['id'],
      bookingNumber: json['bookingNumber'] ?? '',
      userId: json['userId'],
      userName: json['userName'],
      venueId: json['venueId'],
      venueName: json['venueName'] ?? '',
      venueLocation: json['venueLocation'],
      location: json['venueLocation'] ?? json['location'],
      bookingDate: DateTime.parse(json['bookingDate']),
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      duration: (json['duration'] ?? 0).toDouble(),
      pricePerHour: (json['pricePerHour'] ?? 0).toDouble(),
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      discountAmount:
          json['discountAmount'] != null
              ? (json['discountAmount'] as num).toDouble()
              : null,
      discountPercentage:
          json['discountPercentage'] != null
              ? (json['discountPercentage'] as num).toDouble()
              : null,
      status: mapStatus(json['status']),
      paymentStatus: mapPaymentStatus(json['paymentStatus']),
      courtName: json['courtName'],
      courtId: json['courtId'],
      notes: json['notes'],
      venueImageUrl: json['venueImageUrl'],
    );
  }

  String get timeSlot {
    final startHour = startTime.hour.toString().padLeft(2, '0');
    final startMinute = startTime.minute.toString().padLeft(2, '0');
    final endHour = endTime.hour.toString().padLeft(2, '0');
    final endMinute = endTime.minute.toString().padLeft(2, '0');
    return '$startHour:$startMinute - $endHour:$endMinute';
  }

  DateTime get date => bookingDate;
  double get totalAmount => totalPrice;
}
