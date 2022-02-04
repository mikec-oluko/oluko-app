import 'package:flutter/material.dart';
import 'package:oluko_app/helpers/coach_notification_content.dart';
import 'package:oluko_app/helpers/coach_segment_content.dart';
import 'package:oluko_app/models/annotation.dart';
import 'package:oluko_app/models/coach_timeline_item.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/segment_submission.dart';
import 'package:oluko_app/models/submodels/course_timeline_submodel.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'coach_recommendation_default.dart';
import 'coach_timeline_content.dart';

String defaultIdForAllContentTimeline = '0';

class CoachTimelineFunctions {
  static List<CoachTimelineGroup> buildContentForTimelinePanel(
      {List<CoachTimelineItem> timelineItemsContent, List<String> enrolledCourseIdList}) {
    List<String> listOfCourseId = [];
    List<CoachTimelineGroup> timelineTabsAndContent = [];
    List<CoachTimelineItem> contentForItem = [];
    CoachTimelineGroup newTimelineTabItem;

    timelineItemsContent.forEach((timelineItem) {
      !listOfCourseId.contains(timelineItem.course.id) && enrolledCourseIdList.contains(timelineItem.course.id)
          ? listOfCourseId.add(timelineItem.course.id)
          : null;
    });
    listOfCourseId.forEach((courseId) {
      final repeatedItemsQuery = timelineItemsContent.where((timelineItem) => timelineItem.course.id == courseId).toList();
      String itemId;
      String itemName;
      if (repeatedItemsQuery.isNotEmpty) {
        itemId = repeatedItemsQuery.first.course.id;
        itemName = repeatedItemsQuery.first.course.name;
        contentForItem = [];
        repeatedItemsQuery.forEach((element) {
          contentForItem.add(element);
        });
        contentForItem.sort((a, b) => b.createdAt.toDate().compareTo(a.createdAt.toDate()));
        newTimelineTabItem = CoachTimelineGroup(courseId: itemId, courseName: itemName, timelineElements: contentForItem);
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
      List<CourseEnrollment> courseEnrollmentList,
      BuildContext context}) {
    if (annotationContent != null) {
      annotationContent.forEach((element) {
        CoachTimelineItem newItem = CoachTimelineItem(
            coachId: element.coachId,
            coachReference: element.coachReference,
            contentDescription: element.id == 'introVideo' ? 'Introduction Video' : OlukoLocalizations.get(context, 'mentoredVideo'),
            contentName: element.id == 'introVideo' ? 'Introduction Video' : element.segmentSubmissionId,
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
            contentName: element.segmentId,
            contentThumbnail: element.video.thumbUrl,
            contentType: 5,
            sentVideosForNavigation: segmentSubmittedContent,
            course: courseEnrollmentList.where((courseEnrolled) => courseEnrolled.id == element.courseEnrollmentId).isNotEmpty
                ? CourseTimelineSubmodel(id: getCourseId(courseEnrollmentList, element), name: getCourseName(courseEnrollmentList, element))
                : CourseTimelineSubmodel(),
            id: courseEnrollmentList.contains(element.courseEnrollmentId)
                ? getCourseId(courseEnrollmentList, element)
                : defaultIdForAllContentTimeline,
            createdAt: element.createdAt);
        if (sentVideos.where((element) => element.contentThumbnail == newItem.contentThumbnail).isEmpty) {
          sentVideos.add(newItem);
        }
      });
    }
  }

  static String getCourseId(List<CourseEnrollment> courseEnrollmentList, SegmentSubmission element) =>
      courseEnrollmentList.where((courseEnrollment) => courseEnrollment.id == element.courseEnrollmentId).first.course.id;
  static String getCourseName(List<CourseEnrollment> courseEnrollmentList, SegmentSubmission element) =>
      courseEnrollmentList.where((courseEnrollment) => courseEnrollment.id == element.courseEnrollmentId).first.course.name;

  static CoachTimelineItem createAnCoachTimelineItem({CoachRecommendationDefault recommendationItem}) {
    CoachTimelineItem newItem = CoachTimelineItem(
        coachId: recommendationItem.coachRecommendation.originUserId,
        coachReference: recommendationItem.coachRecommendation.originUserReference,
        contentDescription: recommendationItem.contentSubtitle,
        contentName: recommendationItem.contentTitle,
        contentThumbnail: recommendationItem.contentImage,
        contentType: recommendationItem.contentTypeIndex,
        course: CourseTimelineSubmodel(),
        courseForNavigation: recommendationItem.courseContent ?? recommendationItem.courseContent,
        movementForNavigation: recommendationItem.movementContent ?? recommendationItem.movementContent,
        id: '0',
        createdAt: recommendationItem.createdAt);
    return newItem;
  }

  static List<CoachNotificationContent> mentoredVideoForInteraction({List<Annotation> annotationContent, BuildContext context}) {
    List<CoachNotificationContent> mentoredVideosAsNotification = [];
    if (annotationContent != null) {
      annotationContent.forEach((annotation) {
        if (annotation.notificationViewed == false) {
          CoachNotificationContent newItem = CoachNotificationContent(
              contentTitle: OlukoLocalizations.get(context, 'mentoredVideo'),
              contentSubtitle: OlukoLocalizations.get(context, 'mentoredVideo'),
              contentDescription: '',
              contentImage: annotation.video.thumbUrl,
              videoUrl: annotation.videoHLS ?? annotation.video.url,
              contentTypeIndex: 4,
              createdAt: annotation.createdAt,
              mentoredContent: annotation);

          if (mentoredVideosAsNotification.where((element) => element.videoUrl == newItem.videoUrl).isEmpty) {
            mentoredVideosAsNotification.add(newItem);
          }
        }
      });
    }
    return mentoredVideosAsNotification;
  }

  static List<CoachNotificationContent> requiredSegmentsForInteraction({List<CoachSegmentContent> requiredSegments, BuildContext context}) {
    List<CoachNotificationContent> requiredSegmentAsNotification = [];

    if (requiredSegments != null) {
      requiredSegments.forEach((segment) {
        if (segment.coachRequest.notificationViewed == false) {
          CoachNotificationContent newItem = CoachNotificationContent(
              contentTitle: segment.segmentName,
              contentSubtitle: segment.className,
              contentDescription: '',
              contentImage: segment.classImage,
              contentTypeIndex: 2,
              coachRequest: segment.coachRequest);

          if (requiredSegmentAsNotification.where((element) => element.contentTitle == newItem.contentTitle).isEmpty) {
            requiredSegmentAsNotification.add(newItem);
          }
        }
      });
    }
    return requiredSegmentAsNotification;
  }

  static List<CoachNotificationContent> coachRecommendationsForInteraction(
      {List<CoachRecommendationDefault> coachRecommendations, BuildContext context}) {
    List<CoachNotificationContent> recommendationsAsNotification = [];

    if (coachRecommendations != null) {
      coachRecommendations.forEach((recommendation) {
        if (recommendation.coachRecommendation.notificationViewed == false) {
          CoachNotificationContent newItem = CoachNotificationContent(
            contentTitle: recommendation.contentTitle,
            contentSubtitle: recommendation.contentSubtitle,
            contentDescription: recommendation.contentDescription,
            contentImage: recommendation.contentImage,
            contentTypeIndex: recommendation.contentTypeIndex,
            createdAt: recommendation.createdAt,
            classContent: recommendation.classContent ?? recommendation.classContent,
            segmentContent: recommendation.segmentContent ?? recommendation.segmentContent,
            coachRequest: recommendation.coachRequest ?? recommendation.coachRequest,
            coachRecommendation: recommendation.coachRecommendation,
            movementContent: recommendation.movementContent ?? recommendation.movementContent,
            mentoredContent: recommendation.mentoredContent ?? recommendation.mentoredContent,
            courseContent: recommendation.courseContent ?? recommendation.courseContent,
            recommendationMediaContent: recommendation.recommendationMedia,
          );

          if (recommendationsAsNotification
              .where((element) =>
                  element.contentTitle == newItem.contentTitle && element.coachRecommendation.id == newItem.coachRecommendation.id)
              .isEmpty) {
            recommendationsAsNotification.add(newItem);
          }
        }
      });
    }
    return recommendationsAsNotification;
  }
}
