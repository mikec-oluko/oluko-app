import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/draw_point.dart';
import 'package:oluko_app/models/video.dart';
import 'Event.dart';
import 'base.dart';

class VideoInfo extends Base {
  String id;
  int duration;
  List<DrawPoint> drawing;
  List<Event> events;
  List<double> markers;
  Video video;

  VideoInfo({
    this.id,
    this.duration,
    this.drawing,
    this.events,
    this.markers,
    this.video,
    Timestamp createdAt,
    String createdBy,
    Timestamp updatedAt,
    String updatedBy,
  }) : super(
            createdBy: createdBy,
            createdAt: createdAt,
            updatedAt: updatedAt,
            updatedBy: updatedBy);

  factory VideoInfo.fromJson(Map<String, dynamic> json) {
    return VideoInfo(
        id: json['id'],
        duration: json['duration'],
        events: List<Event>.from(
            json['events'].map((event) => Event.fromJson(event))),
        markers: List<double>.from(json['markers']),
        video: Video.fromJson(json['video']),
        drawing: List<DrawPoint>.from(
            json['drawing'].map((drawPoint) => DrawPoint.fromJson(drawPoint))),
        createdAt: json['created_at'],
        createdBy: json['created_by']);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'duration': duration,
        'created_at': createdAt == null ? createdAtSentinel : createdAt,
        'created_by': createdBy,
        'updated_at': updatedAt == null ? updatedAtSentinel : updatedAt,
        'updated_by': updatedBy,
        'events': List<dynamic>.from(events.map((event) => event.toJson())),
        'markers': List<dynamic>.from(markers),
        'video': video.toJson(),
        'drawing':
            List<dynamic>.from(drawing.map((drawPoint) => drawPoint.toJson())),
      };
}
