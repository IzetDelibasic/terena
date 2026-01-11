class User {
  int? id;
  String? username;
  String? email;
  String? firstName;
  String? lastName;
  String? phoneNumber;
  DateTime? createdAt;
  bool? isBlocked;
  String? blockReason;
  DateTime? blockedAt;

  User({
    this.id,
    this.username,
    this.email,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.createdAt,
    this.isBlocked,
    this.blockReason,
    this.blockedAt,
  });

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
    email = json['email'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    phoneNumber = json['phone'];
    createdAt =
        json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null;
    isBlocked = json['status'] == 'Blocked' || json['status'] == 1;
    blockReason = json['blockReason'];
    blockedAt =
        json['blockedAt'] != null ? DateTime.parse(json['blockedAt']) : null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['username'] = username;
    data['email'] = email;
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    data['phoneNumber'] = phoneNumber;
    data['createdAt'] = createdAt?.toIso8601String();
    data['isBlocked'] = isBlocked;
    data['blockReason'] = blockReason;
    data['blockedAt'] = blockedAt?.toIso8601String();
    return data;
  }
}
