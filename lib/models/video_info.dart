import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/draw_point.dart';
import 'package:oluko_app/models/event.dart';
import 'package:oluko_app/models/video.dart';


class VideoInfo {
  String id;
  int duration;
  DateTime creationDate;
  String createdBy;
  List<DrawPoint> drawing;
  List<Event> events;
  List<double> markers;
  Video video;

  VideoInfo({
    this.id,
    this.duration,
    this.creationDate,
    this.drawing,
    this.events,
    this.markers,
    this.video,
    this.createdBy,
  });

  factory VideoInfo.fromJson(Map<String, dynamic> json) {
    return VideoInfo(
        id: json['id'],
        duration: json['duration'],
        creationDate: fromTimestampToDate(json['creation_date']),
        createdBy: json['created_by'],
        events: List<Event>.from(
            json['events'].map((event) => Event.fromJson(event))),
        markers: List<double>.from(json['markers']),
        video: Video.fromJson(json['video']),
        drawing: List<DrawPoint>.from(
            json['drawing'].map((drawPoint) => DrawPoint.fromJson(drawPoint))));
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'duration': duration,
        'creation_date': creationDate,
        'created_by': createdBy,
        'events': List<dynamic>.from(events.map((event) => event.toJson())),
        'markers': List<dynamic>.from(markers),
        'video': video.toJson(),
        'drawing':
            List<dynamic>.from(drawing.map((drawPoint) => drawPoint.toJson())),
      };
}

DateTime fromTimestampToDate(Timestamp timestamp) {
  return timestamp.toDate();
}
