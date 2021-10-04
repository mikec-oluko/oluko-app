import 'package:oluko_app/models/coach_timeline_item.dart';
import 'coach_timeline_content.dart';

List<CoachTimelineGroup> buildContentForTimelinePanel(
    List<String> listOfCourseId,
    List<CoachTimelineItem> contentSameCourse,
    List<CoachTimelineItem> contentEachCourse,
    List<CoachTimelineGroup> timelinePanelContent,
    List<CoachTimelineItem> timelineItemsContent) {
  //LISTA DE CURSOS ID-------------------------
  timelineItemsContent.forEach((timelineItem) {
    !listOfCourseId.contains(timelineItem.course.id) ? listOfCourseId.add(timelineItem.course.id) : null;
  });
  //-----------------------------------------

  //REPETIDOS------------------------------
  listOfCourseId.forEach((courseId) {
    final repeatedItemsQuery =
        timelineItemsContent.where((timelineItem) => timelineItem.course.id == courseId).toList();
    repeatedItemsQuery.length > 1
        ? contentSameCourse.addAll(repeatedItemsQuery)
        : contentEachCourse.addAll(repeatedItemsQuery);
  });
  //---------------------------------------------------

  //CURSOS ID'S REPETIDOS------------------------------
  List<String> idListFromSameCourseContent = [];
  contentSameCourse.forEach((element) => !idListFromSameCourseContent.contains(element.course.id)
      ? idListFromSameCourseContent.add(element.course.id)
      : null);
  //-----------------------------------------------------

  //CREACION DE LISTA FINAL------------------------------
  CoachTimelineGroup newTimelineGroupItem;
  idListFromSameCourseContent.forEach((idFromIdList) {
    newTimelineGroupItem =
        mapContentSameCourse(contentSameCourse, idFromIdList, newTimelineGroupItem, timelinePanelContent);
    mapContentEachCourse(contentEachCourse, newTimelineGroupItem, timelinePanelContent);
  });

  return timelinePanelContent;
}

//AGRUPAR CONTENIDO POR CURSO---------------------------------------------------
CoachTimelineGroup mapContentSameCourse(List<CoachTimelineItem> contentSameCourse, String idFromIdList,
    CoachTimelineGroup newTimelineGroupItem, List<CoachTimelineGroup> timelinePanelContent) {
  contentSameCourse.forEach((content) {
    if (content.course.id == idFromIdList) {
      newTimelineGroupItem =
          CoachTimelineGroup(courseId: content.course.id, courseName: content.course.name, timelineElements: [content]);
      if (timelinePanelContent
          .where((timelineContent) => timelineContent.courseId == newTimelineGroupItem.courseId)
          .toList()
          .isEmpty) {
        timelinePanelContent.add(newTimelineGroupItem);
      } else {
        timelinePanelContent.forEach((timelineContent) {
          if (timelineContent.courseId == newTimelineGroupItem.courseId) {
            timelineContent.timelineElements.addAll(newTimelineGroupItem.timelineElements);
          }
        });
      }
    }
  });
  return newTimelineGroupItem;
}
//--------------------------------------------------------------------------------

//AGREGAR CONTENIDO UNICO POR CURSO------------------------------------------------
void mapContentEachCourse(List<CoachTimelineItem> contentEachCourse, CoachTimelineGroup newTimelineGroupItem,
    List<CoachTimelineGroup> timelinePanelContent) {
  contentEachCourse.forEach((courseContent) {
    newTimelineGroupItem = CoachTimelineGroup(
        courseId: courseContent.course.id, courseName: courseContent.course.name, timelineElements: [courseContent]);
    if (timelinePanelContent
        .where((timelineContent) => timelineContent.courseId == newTimelineGroupItem.courseId)
        .toList()
        .isEmpty) {
      timelinePanelContent.add(newTimelineGroupItem);
    }
  });
}
//--------------------------------------------------------------------------------
