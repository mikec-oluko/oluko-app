import 'package:oluko_app/models/coach_timeline_item.dart';

import 'enum_collection.dart';

class CoachTimelineGroup {
  String courseId;
  String courseName;
  List<CoachTimelineItem> timelineElements;
  CoachTimelineGroup({this.courseId, this.courseName, this.timelineElements});
}

class TimelineContentOption {
  TimelineInteractionType option;
  TimelineContentOption({this.option});
  static List<TimelineContentOption> timelineContentType = [
    TimelineContentOption(option: TimelineInteractionType.course),
    TimelineContentOption(option: TimelineInteractionType.classes),
    TimelineContentOption(option: TimelineInteractionType.segment),
    TimelineContentOption(option: TimelineInteractionType.movement),
    TimelineContentOption(option: TimelineInteractionType.mentoredVideo),
    TimelineContentOption(option: TimelineInteractionType.recommendedVideo),
    TimelineContentOption(option: TimelineInteractionType.sentVideo),
    TimelineContentOption(option: TimelineInteractionType.introductionVideo),
    TimelineContentOption(option: TimelineInteractionType.messageVideo),
  ];
  static TimelineInteractionType getTimelineOption(int contentOption) => timelineContentType.elementAt(contentOption).option;
}
