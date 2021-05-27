class VideoTracking {
  String id;
  String drawPoints;

  VideoTracking({
    this.id,
    this.drawPoints,
  });

  factory VideoTracking.fromJson(Map<String, dynamic> json) {
    return VideoTracking(
      id: json['id'],
      drawPoints: json['drawPoints'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'drawPoints': drawPoints,
      };
}
