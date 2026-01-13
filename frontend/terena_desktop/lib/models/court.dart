class Court {
  int? id;
  int? venueId;
  String? venueName;
  String? courtType;
  String? name;
  bool? isAvailable;
  String? maxCapacity;

  Court({
    this.id,
    this.venueId,
    this.venueName,
    this.courtType,
    this.name,
    this.isAvailable,
    this.maxCapacity,
  });

  Court.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    venueId = json['venueId'];
    venueName = json['venueName'];
    courtType = json['courtType'];
    name = json['name'];
    isAvailable = json['isAvailable'];
    maxCapacity = json['maxCapacity'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['venueId'] = venueId;
    data['venueName'] = venueName;
    data['courtType'] = courtType;
    data['name'] = name;
    data['isAvailable'] = isAvailable;
    data['maxCapacity'] = maxCapacity;
    return data;
  }
}

