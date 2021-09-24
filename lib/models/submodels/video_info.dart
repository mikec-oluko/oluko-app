import 'package:oluko_app/models/submodels/draw_point.dart';
import 'package:oluko_app/models/submodels/event.dart';
import 'package:oluko_app/models/submodels/video.dart';

import '../base.dart';

class VideoInfo extends Base {
  List<DrawPoint> drawing;
  List<Event> events;
  List<double> markers;
  Video video;

  VideoInfo({this.drawing, this.events, this.markers, this.video});

  //TODO: missing impl
  // ignore: missing_return
  static VideoInfo fromJson(Object data) {}

  // factory VideoInfo.fromJson(Object json) {
  //   return VideoInfo(
  //     events: List<Event>.from(
  //         json['events'].map((event) => Event.fromJson(event))),
  //     markers: List<double>.from(json['markers']),
  //     video: Video.fromJson(json['video']),
  //     drawing: List<DrawPoint>.from(
  //         json['drawing'].map((drawPoint) => DrawPoint.fromJson(drawPoint))),
  //   );
  // }

  // Map<String, dynamic> toJson() => {
  //       'events': List<dynamic>.from(events.map((event) => event.toJson())),
  //       'markers': List<dynamic>.from(markers),
  //       'video': video.toJson(),
  //       'drawing':
  //           List<dynamic>.from(drawing.map((drawPoint) => drawPoint.toJson())),
  //     };
}
