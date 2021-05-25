class Marker {
  String id;
  double position;

  Marker({
    this.id,
    this.position,
  });

  factory Marker.fromJson(Map<String, dynamic> json) {
    return Marker(
      id: json['id'],
      position: json['position'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'position': position,
      };
}
