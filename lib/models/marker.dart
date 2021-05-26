class Marker {
  String id;
  double position;
  String videoId;

  Marker({
    this.id,
    this.position,
    this.videoId,
  });

  factory Marker.fromJson(Map<String, dynamic> json) {
    return Marker(
      id: json['id'],
      position: json['position'],
      videoId: json['videoId'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'position': position,
        'videoId': videoId,
      };
}
