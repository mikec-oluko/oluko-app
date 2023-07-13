import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/challenge_navigation.dart';
import 'package:oluko_app/helpers/video_player_helper.dart';
import 'package:oluko_app/models/challenge.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/enums/file_type_enum.dart';
import 'package:oluko_app/models/task.dart';
import 'package:oluko_app/models/task_submission.dart';
import 'package:oluko_app/models/transformation_journey_uploads.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/ui/components/challenges_card.dart';
import 'package:oluko_app/ui/components/coach_assessment_card.dart';
import 'package:oluko_app/ui/components/coach_tab_challenge_card.dart';
import 'package:oluko_app/ui/components/coach_tab_segment_card.dart';
import 'package:oluko_app/ui/components/image_and_video_container.dart';
import 'coach_segment_content.dart';
import 'coach_segment_info.dart';
import 'enum_collection.dart';

class TransformListOfItemsToWidget {
  static List<Widget> getWidgetListFromContent(
      {List<TransformationJourneyUpload> tansformationJourneyData,
      List<TaskSubmission> assessmentVideoData,
      List<Challenge> upcomingChallenges,
      List<ChallengeNavigation> challengeSegments,
      ActualProfileRoute requestedFromRoute,
      UserResponse requestedUser,
      bool isEdit = false,
      Function() editAction,
      bool isFriend,
      bool useAudio = true}) {
    final List<Widget> contentForSection = [];

    if (tansformationJourneyData != null && (assessmentVideoData == null && upcomingChallenges == null)) {
      for (final contentUploaded in tansformationJourneyData) {
        contentForSection.add(getImageAndVideoCard(
            transformationJourneyContent: contentUploaded, routeForContent: requestedFromRoute, isEdit: isEdit, editAction: () => editAction));
      }
    }

    if (assessmentVideoData != null && (tansformationJourneyData == null && upcomingChallenges == null)) {
      for (final assessmentVideo in assessmentVideoData) {
        if ((requestedUser.id == assessmentVideo.createdBy) || (assessmentVideo.isPublic && isFriend != false)) {
          contentForSection.add(getImageAndVideoCard(taskSubmissionContent: assessmentVideo, routeForContent: requestedFromRoute));
        }
      }
    }
    if (upcomingChallenges != null && (tansformationJourneyData == null && assessmentVideoData == null)) {
      for (final challenge in upcomingChallenges) {
        contentForSection.add(
            getImageAndVideoCard(upcomingChallengesContent: challenge, routeForContent: requestedFromRoute, requestedUser: requestedUser, useAudio: useAudio));
      }
    }
    if ((challengeSegments != null && upcomingChallenges == null) && (tansformationJourneyData == null && assessmentVideoData == null)) {
      challengeSegments.forEach((challengeSegment) {
        contentForSection.add(
            getImageAndVideoCard(challengeSegment: challengeSegment, routeForContent: requestedFromRoute, requestedUser: requestedUser, useAudio: useAudio));
      });
    }
    return contentForSection.toList();
  }

  //TODO: Update logic to trigger actions depends on contentType and route
  static Widget getImageAndVideoCard(
      {TransformationJourneyUpload transformationJourneyContent,
      TaskSubmission taskSubmissionContent,
      Challenge upcomingChallengesContent,
      ChallengeNavigation challengeSegment,
      ActualProfileRoute routeForContent,
      bool useAudio = false,
      bool isEdit = false,
      Function() editAction,
      UserResponse requestedUser}) {
    Widget contentForReturn = SizedBox();

    if (transformationJourneyContent != null) {
      contentForReturn = Padding(
        padding: const EdgeInsets.all(5.0),
        child: ImageAndVideoContainer(
          backgroundImage: transformationJourneyContent.thumbnail,
          isContentVideo: transformationJourneyContent.type == FileTypeEnum.video ? true : false,
          videoUrl: transformationJourneyContent.file,
          displayOnViewNamed: routeForContent,
          originalContent: transformationJourneyContent,
          editAction: editAction,
          isEdit: isEdit,
        ),
      );
    }
    if (taskSubmissionContent != null && taskSubmissionContent.video != null) {
      contentForReturn = Padding(
        padding: const EdgeInsets.all(5.0),
        child: ImageAndVideoContainer(
          backgroundImage: taskSubmissionContent.video.thumbUrl != null ? taskSubmissionContent.video.thumbUrl : '',
          isContentVideo: taskSubmissionContent.video != null,
          videoUrl: VideoPlayerHelper.getVideoFromSourceActive(videoHlsUrl: taskSubmissionContent.videoHls, videoUrl: taskSubmissionContent.video.url),
          originalContent: taskSubmissionContent,
          displayOnViewNamed: routeForContent,
        ),
      );
    }
    if (upcomingChallengesContent != null) {
      contentForReturn = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: ChallengesCard(
            segmentChallenge: upcomingChallengesContent as ChallengeNavigation, routeToGo: "/", userRequested: requestedUser, useAudio: useAudio),
      );
    }
    if (challengeSegment != null) {
      contentForReturn = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: ChallengesCard(
          segmentChallenge: challengeSegment,
          userRequested: requestedUser,
          useAudio: useAudio,
          navigateToSegment: true,
        ),
      );
    }
    return contentForReturn;
  }

  static List<Widget> coachChallengesAndSegments({List<CoachSegmentContent> segments}) {
    final List<Widget> contentForSection = [];
    if (segments.isNotEmpty) {
      for (final segment in segments) {
        if (segment.completedAt == null) {
          contentForSection.add(returnCardForChallenge(segment));
        }
      }
    }
    return contentForSection;
  }

  static Widget returnCardForChallenge(CoachSegmentContent challengeSegment) {
    Widget contentForReturn = SizedBox();
    contentForReturn = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: CoachTabChallengeCard(challenge: challengeSegment),
    );
    return contentForReturn;
  }

  static Widget returnCardForSegment(CoachSegmentContent segment) {
    Widget contentForReturn = SizedBox();
    contentForReturn = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: GestureDetector(onTap: () {}, child: CoachTabSegmentCard(segment: segment)),
    );
    return contentForReturn;
  }

  static List<Widget> getAssessmentCards({List<Task> tasks, List<TaskSubmission> tasksSubmitted, bool introductionVideoDone, bool verticalList}) {
    final List<Widget> contentForSection = [];
    for (final task in tasks) {
      contentForSection.add(returnCardForAssessment(task, tasksSubmitted, introductionVideoDone, OlukoNeumorphism.isNeumorphismDesign));
    }
    return contentForSection;
  }

  static Widget returnCardForAssessment(Task task, List<TaskSubmission> tasksSubmitted, bool introductionVideoDone, bool isVerticalList) {
    return Padding(
        padding: const EdgeInsets.all(5.0),
        child: CoachAssessmentCard(
          isAssessmentTask: true,
          isForVerticalList: isVerticalList,
          task: task,
          assessmentVideos: tasksSubmitted,
          introductionVideoDone: introductionVideoDone,
        ));
  }

  static List<InfoForSegments> segments(List<CourseEnrollment> courseEnrollments) {
    final List<InfoForSegments> listOfSegments = [];
    String className;
    String classImage;
    int classIndex;
    int courseIndex;
    for (final courseEnrollment in courseEnrollments) {
      for (final classToCheck in courseEnrollment.classes) {
        className = classToCheck.name;
        classImage = classToCheck.image;
        classIndex = courseEnrollment.classes.indexOf(classToCheck);
        courseIndex = courseEnrollments.indexOf(courseEnrollment);
        final InfoForSegments infoForSegmentElement = InfoForSegments(
          classImage: classImage,
          courseEnrollment: courseEnrollment,
          classIndex: classIndex,
          courseIndex: courseIndex,
          className: className,
          enrollmentSegments: [],
        );
        for (final segment in classToCheck.segments) {
          infoForSegmentElement.enrollmentSegments.add(segment);
        }
        listOfSegments.add(infoForSegmentElement);
      }
    }
    return listOfSegments;
  }

  static List<CoachSegmentContent> createSegmentContentInforamtion(List<InfoForSegments> segments, List<Challenge> challenges) {
    final List<CoachSegmentContent> coachSegmentContentList = [];
    for (var challenge in challenges) {
      CoachSegmentContent coachSegmentContent = CoachSegmentContent(
          segmentId: challenge.segmentId,
          classImage: challenge.image,
          completedAt: challenge.completedAt,
          segmentReference: challenge.segmentReference,
          isChallenge: true,
          indexClass: challenge.indexClass,
          indexSegment: challenge.indexSegment);
      for (final segment in segments) {
        for (final actualSegment in segment.enrollmentSegments) {
          if (challenge.segmentId == actualSegment.id && challenge.courseEnrollmentId == segment.courseEnrollment.id) {
            coachSegmentContent.segmentName = actualSegment.name;
            coachSegmentContent.indexCourse = segment.courseIndex;
            coachSegmentContent.courseEnrollment = segment.courseEnrollment;
          }
        }
      }
      coachSegmentContentList.add(coachSegmentContent);
    }
    return coachSegmentContentList;
  }
}
