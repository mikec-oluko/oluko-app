import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/submodels/draw_point.dart';
import 'package:oluko_app/models/submodels/event.dart';
import 'package:oluko_app/models/submodels/video.dart';
import 'base.dart';

class VideoInfo extends Base {
  List<DrawPoint> drawing;
  List<Event> events;
  List<double> markers;
  Video video;

  VideoInfo(
      {String id,
      this.drawing,
      this.events,
      this.markers,
      this.video,
      Timestamp createdAt,
      String createdBy,
      Timestamp updatedAt,
      String updatedBy,
      bool isHidden,
      bool isDeleted})
      : super(
            id: id,
            createdBy: createdBy,
            createdAt: createdAt,
            updatedAt: updatedAt,
            updatedBy: updatedBy,
            isDeleted: isDeleted,
            isHidden: isHidden);

  factory VideoInfo.fromJson(Map<String, dynamic> json) {
    VideoInfo videoInfo = VideoInfo(
      events: List<Event>.from(
          json['events'].map((event) => Event.fromJson(event))),
      markers: List<double>.from(json['markers']),
      video: Video.fromJson(json['video']),
      drawing: List<DrawPoint>.from(
          json['drawing'].map((drawPoint) => DrawPoint.fromJson(drawPoint))),
    );
    videoInfo.setBase(json);
    return videoInfo;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> videoInfoJson = {
      'events': List<dynamic>.from(events.map((event) => event.toJson())),
      'markers': List<dynamic>.from(markers),
      'video': video.toJson(),
      'drawing':
          List<dynamic>.from(drawing.map((drawPoint) => drawPoint.toJson())),
    };
    videoInfoJson.addEntries(super.toJson().entries);
    return videoInfoJson;
  }
}
