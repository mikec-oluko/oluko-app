import 'package:oluko_app/models/coach_timeline_item.dart';
import 'coach_timeline_content.dart';

List<CoachTimelineGroup> buildContentForTimelinePanel(List<CoachTimelineItem> timelineItemsContent) {
  List<String> listOfCourseId = [];
  List<CoachTimelineGroup> contentToReturn = [];
  List<CoachTimelineItem> contentForItem = [];
  CoachTimelineGroup newTimelineGroupItem;

  timelineItemsContent.forEach((timelineItem) {
    !listOfCourseId.contains(timelineItem.course.id) ? listOfCourseId.add(timelineItem.course.id) : null;
  });
  listOfCourseId.forEach((courseId) {
    final repeatedItemsQuery =
        timelineItemsContent.where((timelineItem) => timelineItem.course.id == courseId).toList();
    String itemId;
    String itemName;
    if (repeatedItemsQuery.length > 1) {
      itemId = repeatedItemsQuery.first.course.id;
      itemName = repeatedItemsQuery.first.course.name;
      contentForItem = [];
      repeatedItemsQuery.forEach((element) {
        contentForItem.add(element);
      });
      contentForItem.sort((a, b) => b.createdAt.toDate().compareTo(a.createdAt.toDate()));
      newTimelineGroupItem =
          CoachTimelineGroup(courseId: itemId, courseName: itemName, timelineElements: contentForItem);
    } else {
      newTimelineGroupItem = CoachTimelineGroup(
          courseId: repeatedItemsQuery.first.course.id,
          courseName: repeatedItemsQuery.first.course.name,
          timelineElements: [repeatedItemsQuery.first]);
    }
    contentToReturn.add(newTimelineGroupItem);
  });

  return contentToReturn;
}
