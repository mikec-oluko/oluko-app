import 'package:flutter/material.dart';
import 'package:oluko_app/blocs/coach/coach_assignment_bloc.dart';
import 'package:oluko_app/helpers/coach_notification_content.dart';
import 'package:oluko_app/helpers/coach_recommendation_default.dart';
import 'package:oluko_app/helpers/coach_segment_content.dart';
import 'package:oluko_app/helpers/coach_timeline_content.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/models/annotation.dart';
import 'package:oluko_app/models/coach_media_message.dart';
import 'package:oluko_app/models/coach_timeline_item.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/segment_submission.dart';
import 'package:oluko_app/models/submodels/course_timeline_submodel.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

const String defaultIdForAllContentTimeline = '0';
const String defaultIntroVideoId = 'introVideo';
const String defaultIntroVideoTitle = 'Introduction Video';

class CoachTimelineFunctions {
  static List<CoachTimelineGroup> buildContentForTimelinePanel({List<CoachTimelineItem> timelineItemsContent, List<String> enrolledCourseIdList}) {
    List<String> listOfCourseId = [];
    List<CoachTimelineGroup> timelineTabsAndContent = [];
    List<CoachTimelineItem> contentForItem = [];
    CoachTimelineGroup newTimelineTabItem;
    if (timelineItemsContent.isNotEmpty) {
      timelineItemsContent.forEach((timelineItem) {
        !listOfCourseId.contains(timelineItem.course.id) &&
                (timelineItem.course.id == defaultIdForAllContentTimeline || enrolledCourseIdList.contains(timelineItem.course.id))
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
              courseId: repeatedItemsQuery.first.course.id, courseName: repeatedItemsQuery.first.course.name, timelineElements: [repeatedItemsQuery.first]);
        }
        timelineTabsAndContent.add(newTimelineTabItem);
      });
    }
    return timelineTabsAndContent;
  }

  static List<CoachTimelineItem> addWelcomeVideoToTimeline(
      {@required BuildContext context, @required Annotation welcomeVideo, @required List<CoachTimelineItem> timelineItems}) {
    welcomeVideo != null && timelineItems != null
        ? timelineItems.where((element) => element.contentName == defaultIntroVideoTitle).toList().isEmpty
            ? timelineItems.insert(0, createTimelineItem(welcomeVideo, context))
            : null
        : null;

    return timelineItems;
  }

  static CoachTimelineItem createTimelineItem(Annotation welcomeVideo, BuildContext context) {
    return CoachTimelineItem(
        coachId: welcomeVideo.coachId,
        coachReference: welcomeVideo.coachReference,
        contentDescription: welcomeVideo.id == defaultIntroVideoId ? defaultIntroVideoTitle : OlukoLocalizations.get(context, 'personalizedVideo'),
        contentName: welcomeVideo.id == defaultIntroVideoId ? defaultIntroVideoTitle : welcomeVideo.segmentSubmissionId,
        contentThumbnail: welcomeVideo.video.thumbUrl,
        contentType: welcomeVideo.id == defaultIntroVideoId ? TimelineInteractionType.introductionVideo : TimelineInteractionType.mentoredVideo,
        mentoredVideosForNavigation: [welcomeVideo],
        course: CourseTimelineSubmodel(
          name: OlukoLocalizations.get(context, 'all'),
        ),
        id: defaultIdForAllContentTimeline,
        createdAt: welcomeVideo.createdAt);
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
            contentDescription: element.id == defaultIntroVideoId ? defaultIntroVideoTitle : OlukoLocalizations.get(context, 'personalizedVideo'),
            contentName: element.id == defaultIntroVideoId ? defaultIntroVideoTitle : element.segmentSubmissionId,
            contentThumbnail: element.video.thumbUrl,
            contentType: element.id == defaultIntroVideoId ? TimelineInteractionType.introductionVideo : TimelineInteractionType.mentoredVideo,
            mentoredVideosForNavigation: annotationContent,
            course: CourseTimelineSubmodel(
              name: OlukoLocalizations.get(context, 'all'),
            ),
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
            contentType: TimelineInteractionType.sentVideo,
            sentVideosForNavigation: segmentSubmittedContent,
            course: courseEnrollmentList.where((courseEnrolled) => courseEnrolled.id == element.courseEnrollmentId).isNotEmpty
                ? CourseTimelineSubmodel(id: getCourseId(courseEnrollmentList, element), name: getCourseName(courseEnrollmentList, element))
                : CourseTimelineSubmodel(name: OlukoLocalizations.get(context, 'all')),
            id: courseEnrollmentList.contains(element.courseEnrollmentId) ? getCourseId(courseEnrollmentList, element) : defaultIdForAllContentTimeline,
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
        contentType: recommendationItem.contentType,
        course: CourseTimelineSubmodel(),
        courseForNavigation: recommendationItem.courseContent ?? recommendationItem.courseContent,
        movementForNavigation: recommendationItem.movementContent ?? recommendationItem.movementContent,
        coachMediaMessage: recommendationItem.coachMediaMessage ?? recommendationItem.coachMediaMessage,
        recommendationMedia: recommendationItem.recommendationMedia ?? recommendationItem.recommendationMedia,
        id: '0',
        createdAt: recommendationItem.createdAt);
    return newItem;
  }

  static List<CoachNotificationContent> mentoredVideoForInteraction({List<Annotation> annotationContent, BuildContext context}) {
    const String _defaultIntroductionVideoId = 'introVideo';
    List<CoachNotificationContent> mentoredVideosAsNotification = [];
    if (annotationContent != null) {
      annotationContent.forEach((annotation) {
        if (annotation.notificationViewed == false) {
          CoachNotificationContent newItem = CoachNotificationContent(
              contentTitle: annotation.id != _defaultIntroductionVideoId
                  ? OlukoLocalizations.get(context, 'personalizedVideo')
                  : OlukoLocalizations.get(context, 'introductionVideo'),
              contentSubtitle: annotation.id != _defaultIntroductionVideoId
                  ? OlukoLocalizations.get(context, 'personalizedVideo')
                  : OlukoLocalizations.get(context, 'introductionVideo'),
              contentDescription: '',
              contentImage: annotation.video.thumbUrl,
              videoUrl: annotation.videoHLS ?? annotation.video.url,
              contentType: annotation.id != _defaultIntroductionVideoId ? TimelineInteractionType.mentoredVideo : TimelineInteractionType.introductionVideo,
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

  static List<CoachNotificationContent> messageVideoForInteraction({List<CoachMediaMessage> messageVideoContent, BuildContext context}) {
    List<CoachNotificationContent> messageVideoAsNotification = [];
    if (messageVideoContent != null) {
      messageVideoContent.forEach((messageVideo) {
        if (messageVideo.viewed == false) {
          CoachNotificationContent newItem = CoachNotificationContent(
              contentTitle: OlukoLocalizations.get(context, 'coachMessageVideo'),
              contentSubtitle: OlukoLocalizations.get(context, 'coachMessageVideo'),
              contentDescription: '',
              contentImage: messageVideo.video.thumbUrl,
              videoUrl: messageVideo.videoHls ?? messageVideo.video.url,
              contentType: TimelineInteractionType.messageVideo,
              createdAt: messageVideo.createdAt,
              coachMediaMessage: messageVideo);

          if (messageVideoAsNotification.where((element) => element.videoUrl == newItem.videoUrl).isEmpty) {
            messageVideoAsNotification.add(newItem);
          }
        }
      });
    }
    return messageVideoAsNotification;
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
              contentType: TimelineInteractionType.segment,
              coachRequest: segment.coachRequest);

          if (requiredSegmentAsNotification.where((element) => element.contentTitle == newItem.contentTitle).isEmpty) {
            requiredSegmentAsNotification.add(newItem);
          }
        }
      });
    }
    return requiredSegmentAsNotification;
  }

  static List<CoachNotificationContent> coachRecommendationsForInteraction({List<CoachRecommendationDefault> coachRecommendations, BuildContext context}) {
    List<CoachNotificationContent> recommendationsAsNotification = [];

    if (coachRecommendations != null) {
      coachRecommendations.forEach((recommendation) {
        if (recommendation.coachRecommendation.notificationViewed == false) {
          CoachNotificationContent newItem = CoachNotificationContent(
            contentTitle: recommendation.contentTitle,
            contentSubtitle: recommendation.contentSubtitle,
            contentDescription: recommendation.contentDescription,
            contentImage: recommendation.contentImage,
            contentType: recommendation.contentType,
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
              .where((element) => element.contentTitle == newItem.contentTitle && element.coachRecommendation.id == newItem.coachRecommendation.id)
              .isEmpty) {
            recommendationsAsNotification.add(newItem);
          }
        }
      });
    }
    return recommendationsAsNotification;
  }

  static List<CoachTimelineGroup> timelinePanelUpdateTabsAndContent(CoachTimelineGroup allTabContent, List<CoachTimelineGroup> timelinePanelContent,
      {bool isForFriend = false}) {
    if (timelinePanelContent != null && timelinePanelContent.isNotEmpty) {
      final indexForAllTab = timelinePanelContent.indexWhere((panelItem) => panelItem.courseId == allTabContent.courseId);
      if (indexForAllTab != -1) {
        allTabContent.timelineElements.forEach((allTabNewContent) {
          addContentToTimeline(timelineGroup: timelinePanelContent[indexForAllTab], newContent: allTabNewContent);
        });
        timelinePanelContent.insert(0, timelinePanelContent[indexForAllTab]);
        timelinePanelContent.removeAt(indexForAllTab + 1);
      } else {
        if (timelinePanelContent[0] != null && timelinePanelContent[0].courseId == allTabContent.courseId) {
          allTabContent.timelineElements.forEach((allTabNewContent) {
            addContentToTimeline(timelineGroup: timelinePanelContent[0], newContent: allTabNewContent);
          });
        } else {
          allTabContent.timelineElements.sort((a, b) => b.createdAt.toDate().compareTo(a.createdAt.toDate()));
          timelinePanelContent.insert(0, allTabContent);
        }
      }
    } else {
      allTabContent.timelineElements.sort((a, b) => b.createdAt.toDate().compareTo(a.createdAt.toDate()));
      timelinePanelContent.insert(0, allTabContent);
    }
    return timelinePanelContent;
  }

  static void addContentToTimeline({CoachTimelineGroup timelineGroup, CoachTimelineItem newContent}) {
    final existingContent = timelineGroup.timelineElements.where((timelineElement) => timelineElement.contentName == newContent.contentName).toList();
    if (existingContent.isEmpty) {
      timelineGroup.timelineElements.add(newContent);
      timelineGroup.timelineElements.sort((a, b) => b.createdAt.toDate().compareTo(a.createdAt.toDate()));
    } else if (newContent.contentType == TimelineInteractionType.mentoredVideo || newContent.contentType == TimelineInteractionType.messageVideo) {
      existingContent.forEach((content) {
        if ((content.createdAt.toDate() != newContent.createdAt.toDate()) && content.contentType == newContent.contentType) {
          if (!timelineGroup.timelineElements.contains(newContent)) {
            timelineGroup.timelineElements.add(newContent);
          }
        }
      });
      timelineGroup.timelineElements.sort((a, b) => b.createdAt.toDate().compareTo(a.createdAt.toDate()));
    }
  }

  static List<CoachTimelineGroup> getTimelineContentForPanel(BuildContext context,
      {@required List<CoachTimelineGroup> timelineContentTabs,
      @required List<CoachTimelineItem> timelineItemsFromState,
      @required List<CoachTimelineItem> allContent,
      @required List<String> listOfCoursesId,
      bool isForFriend = false}) {
    List<CoachTimelineGroup> _updatedContent = [];
    const String _defaultIdForAllContentTimeline = '0';

    _updatedContent = timelineContentTabs;
    _updatedContent = buildContentForTimelinePanel(timelineItemsContent: timelineItemsFromState, enrolledCourseIdList: listOfCoursesId);

    _updatedContent.forEach((timelinePanelElement) {
      timelinePanelElement.timelineElements.forEach((timelineContentItem) {
        if (allContent.where((allContentItem) => allContentItem.contentName == timelineContentItem.contentName).isEmpty) {
          allContent.add(timelineContentItem);
        }
      });
    });
    CoachTimelineGroup allTabContent =
        CoachTimelineGroup(courseId: _defaultIdForAllContentTimeline, courseName: OlukoLocalizations.get(context, 'all'), timelineElements: allContent);
    allTabContent.timelineElements.sort((a, b) => b.createdAt.toDate().compareTo(a.createdAt.toDate()));
    return isForFriend ? [allTabContent] : timelinePanelUpdateTabsAndContent(allTabContent, _updatedContent, isForFriend: isForFriend);
  }

  static List<CoachTimelineItem> coachRecommendationsTimelineItems(List<CoachRecommendationDefault> coachRecommendationList) {
    List<CoachTimelineItem> _coachRecommendationTimelineContent = [];
    if (coachRecommendationList != null && coachRecommendationList.isNotEmpty) {
      coachRecommendationList.forEach((coachRecommendation) {
        final newRecommendationForTimeline = createAnCoachTimelineItem(recommendationItem: coachRecommendation);
        if (!_coachRecommendationTimelineContent.contains(newRecommendationForTimeline)) {
          _coachRecommendationTimelineContent.add(newRecommendationForTimeline);
        }
      });
    }
    return _coachRecommendationTimelineContent;
  }
}
