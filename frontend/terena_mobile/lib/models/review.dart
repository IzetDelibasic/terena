class Review {
  final int? id;
  final int rating;
  final String? comment;
  final DateTime? createdAt;
  final int userId;
  final String? userUsername;
  final int venueId;
  final String? venueName;
  final int? bookingId;

  Review({
    this.id,
    required this.rating,
    this.comment,
    this.createdAt,
    required this.userId,
    this.userUsername,
    required this.venueId,
    this.venueName,
    this.bookingId,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      rating: json['rating'] ?? 0,
      comment: json['comment'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      userId: json['userId'] ?? 0,
      userUsername: json['userUsername'],
      venueId: json['venueId'] ?? 0,
      venueName: json['venueName'],
      bookingId: json['bookingId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt?.toIso8601String(),
      'userId': userId,
      'userUsername': userUsername,
      'venueId': venueId,
      'venueName': venueName,
      'bookingId': bookingId,
    };
  }
}
