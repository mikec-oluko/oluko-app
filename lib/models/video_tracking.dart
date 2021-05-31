import 'package:oluko_app/models/draw_point.dart';

class VideoTracking {
  String id;
  List<DrawPoint> drawPoints;

  VideoTracking({
    this.id,
    this.drawPoints,
  });

  factory VideoTracking.fromJson(Map<String, dynamic> json) {
    return VideoTracking(
      id: json['id'],
      drawPoints: List<DrawPoint>.from(
          json['draw_points'].map((point) => DrawPoint.fromJson(point))),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'draw_points':
            List<dynamic>.from(drawPoints.map((point) => point.toJson())),
      };
}
