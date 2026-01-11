class Review {
  int? id;
  int? rating;
  String? comment;
  DateTime? createdAt;
  int? userId;
  String? userUsername;
  int? venueId;
  String? venueName;
  int? bookingId;

  Review({
    this.id,
    this.rating,
    this.comment,
    this.createdAt,
    this.userId,
    this.userUsername,
    this.venueId,
    this.venueName,
    this.bookingId,
  });

  Review.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    rating = json['rating'];
    comment = json['comment'];
    createdAt =
        json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null;
    userId = json['userId'];
    userUsername = json['userUsername'];
    venueId = json['venueId'];
    venueName = json['venueName'];
    bookingId = json['bookingId'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['rating'] = rating;
    data['comment'] = comment;
    data['createdAt'] = createdAt?.toIso8601String();
    data['userId'] = userId;
    data['userUsername'] = userUsername;
    data['venueId'] = venueId;
    data['venueName'] = venueName;
    data['bookingId'] = bookingId;
    return data;
  }
}
