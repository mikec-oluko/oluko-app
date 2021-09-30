import 'package:oluko_app/models/coach_timeline_item.dart';

class CoachTimelineGroup {
  String courseId;
  String courseName;
  List<CoachTimelineItem> timelineElements;
  CoachTimelineGroup({this.courseId, this.courseName, this.timelineElements});
}
