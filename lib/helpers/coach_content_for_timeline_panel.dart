import 'package:flutter/material.dart';
import 'package:oluko_app/models/annotations.dart';
import 'package:oluko_app/models/coach_timeline_item.dart';
import 'package:oluko_app/models/segment_submission.dart';
import 'package:oluko_app/models/submodels/course_timeline_submodel.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'coach_timeline_content.dart';

String defaultIdForAllContentTimeline = '0';

class CoachTimelineFunctions {
  static List<CoachTimelineGroup> buildContentForTimelinePanel(List<CoachTimelineItem> timelineItemsContent) {
    List<String> listOfCourseId = [];
    List<CoachTimelineGroup> timelineTabsAndContent = [];
    List<CoachTimelineItem> contentForItem = [];
    CoachTimelineGroup newTimelineTabItem;

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
        newTimelineTabItem =
            CoachTimelineGroup(courseId: itemId, courseName: itemName, timelineElements: contentForItem);
      } else {
        newTimelineTabItem = CoachTimelineGroup(
            courseId: repeatedItemsQuery.first.course.id,
            courseName: repeatedItemsQuery.first.course.name,
            timelineElements: [repeatedItemsQuery.first]);
      }
      timelineTabsAndContent.add(newTimelineTabItem);
    });

    return timelineTabsAndContent;
  }

  static void getTimelineVideoContent(
      {List<Annotation> annotationContent,
      List<CoachTimelineItem> mentoredVideos,
      List<SegmentSubmission> segmentSubmittedContent,
      List<CoachTimelineItem> sentVideos,
      BuildContext context}) {
    if (annotationContent != null) {
      annotationContent.forEach((element) {
        CoachTimelineItem newItem = CoachTimelineItem(
            coachId: element.coachId,
            coachReference: element.coachReference,
            contentDescription: OlukoLocalizations.get(context, 'mentoredVideo'),
            contentName: OlukoLocalizations.get(context, 'mentoredVideo'),
            contentThumbnail: element.video.thumbUrl,
            contentType: 4,
            mentoredVideosForNavigation: annotationContent,
            course: CourseTimelineSubmodel(),
            id: defaultIdForAllContentTimeline,
            createdAt: element.createdAt);
        if (mentoredVideos.where((element) => element.contentThumbnail == newItem.contentThumbnail).isEmpty) {
          mentoredVideos.add(newItem);
        }
      });
    }

    if (segmentSubmittedContent != null) {
      segmentSubmittedContent.forEach((element) {
        CoachTimelineItem newItem = CoachTimelineItem(
            coachId: element.coachId,
            coachReference: element.coachReference,
            contentDescription: OlukoLocalizations.get(context, 'sentVideo'),
            contentName: OlukoLocalizations.get(context, 'sentVideo'),
            contentThumbnail: element.video.thumbUrl,
            contentType: 5,
            sentVideosForNavigation: segmentSubmittedContent,
            course: CourseTimelineSubmodel(),
            id: defaultIdForAllContentTimeline,
            createdAt: element.createdAt);
        if (sentVideos.where((element) => element.contentThumbnail == newItem.contentThumbnail).isEmpty) {
          sentVideos.add(newItem);
        }
      });
    }
  }
}
