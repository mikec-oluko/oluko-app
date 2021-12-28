import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
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
      ActualProfileRoute requestedFromRoute,
      UserResponse requestedUser,
      bool isFriend,
      bool useAudio = true}) {
    final List<Widget> contentForSection = [];

    if (tansformationJourneyData != null && (assessmentVideoData == null && upcomingChallenges == null)) {
      for (final contentUploaded in tansformationJourneyData) {
        contentForSection.add(getImageAndVideoCard(transformationJourneyContent: contentUploaded, routeForContent: requestedFromRoute));
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
        contentForSection.add(getImageAndVideoCard(
            upcomingChallengesContent: challenge, routeForContent: requestedFromRoute, requestedUser: requestedUser, useAudio: useAudio));
      }
    }
    return contentForSection.toList();
  }

  //TODO: Update logic to trigger actions depends on contentType and route
  static Widget getImageAndVideoCard(
      {TransformationJourneyUpload transformationJourneyContent,
      TaskSubmission taskSubmissionContent,
      Challenge upcomingChallengesContent,
      ActualProfileRoute routeForContent,
      bool useAudio = false,
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
        ),
      );
    }
    if (taskSubmissionContent != null && taskSubmissionContent.video != null) {
      contentForReturn = Padding(
        padding: const EdgeInsets.all(5.0),
        child: ImageAndVideoContainer(
          backgroundImage: taskSubmissionContent.video.thumbUrl != null ? taskSubmissionContent.video.thumbUrl : '',
          isContentVideo: taskSubmissionContent.video != null,
          videoUrl: taskSubmissionContent.video.url != null ? taskSubmissionContent.video.url : '',
          originalContent: taskSubmissionContent,
          displayOnViewNamed: routeForContent,
        ),
      );
    }
    if (upcomingChallengesContent != null) {
      contentForReturn = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: ChallengesCard(challenge: upcomingChallengesContent, routeToGo: "/", userRequested: requestedUser, useAudio: useAudio),
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

  static List<Widget> getAssessmentCards({List<Task> tasks, List<TaskSubmission> tasksSubmitted, bool introductionVideoDone}) {
    final List<Widget> contentForSection = [];
    for (final task in tasks) {
      contentForSection.add(returnCardForAssessment(task, tasksSubmitted, introductionVideoDone));
    }
    return contentForSection;
  }

  static Widget returnCardForAssessment(Task task, List<TaskSubmission> tasksSubmitted, bool introductionVideoDone) {
    return Padding(
        padding: const EdgeInsets.all(5.0),
        child: CoachAssessmentCard(
          task: task,
          assessmentVideos: tasksSubmitted,
          introductionVideoDone: introductionVideoDone,
        ));
  }

  static List<InfoForSegments> segments(List<CourseEnrollment> courseEnrollments) {
    final List<InfoForSegments> listOfSegments = [];
    String className;
    String classImage;

    for (final courseEnrollment in courseEnrollments) {
      for (final classToCheck in courseEnrollment.classes) {
        className = classToCheck.name;
        classImage = classToCheck.image;
        final InfoForSegments infoForSegmentElement = InfoForSegments(classImage: classImage, className: className, segments: []);
        for (final segment in classToCheck.segments) {
          infoForSegmentElement.segments.add(segment);
        }
        listOfSegments.add(infoForSegmentElement);
      }
    }
    return listOfSegments;
  }

  static List<CoachSegmentContent> createSegmentContentInforamtion(List<InfoForSegments> segments) {
    final List<CoachSegmentContent> coachSegmentContent = [];

    for (final segment in segments) {
      for (final actualSegment in segment.segments) {
        coachSegmentContent.add(CoachSegmentContent(
            segmentId: actualSegment.id,
            classImage: segment.classImage,
            className: segment.className,
            segmentName: actualSegment.name,
            completedAt: actualSegment.completedAt,
            segmentReference: actualSegment.reference,
            isChallenge: actualSegment.isChallenge));
      }
    }
    return coachSegmentContent;
  }
}
