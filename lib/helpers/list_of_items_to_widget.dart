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
import 'package:oluko_app/utils/oluko_localizations.dart';

import 'coach_segment_content.dart';
import 'coach_segment_info.dart';
import 'enum_collection.dart';

class TransformListOfItemsToWidget {
  static List<Widget> getWidgetListFromContent(
      {List<TransformationJourneyUpload> tansformationJourneyData,
      List<TaskSubmission> assessmentVideoData,
      List<Challenge> upcomingChallenges,
      ActualProfileRoute requestedFromRoute,
      UserResponse requestedUser}) {
    List<Widget> contentForSection = [];

    if (tansformationJourneyData != null && (assessmentVideoData == null && upcomingChallenges == null)) {
      tansformationJourneyData.forEach((contentUploaded) {
        contentForSection.add(
            getImageAndVideoCard(transformationJourneyContent: contentUploaded, routeForContent: requestedFromRoute));
      });
    }

    if (assessmentVideoData != null && (tansformationJourneyData == null && upcomingChallenges == null)) {
      assessmentVideoData.forEach((assessmentVideo) {
        contentForSection
            .add(getImageAndVideoCard(taskSubmissionContent: assessmentVideo, routeForContent: requestedFromRoute));
      });
    }

    if (upcomingChallenges != null && (tansformationJourneyData == null && assessmentVideoData == null)) {
      upcomingChallenges.forEach((challenge) {
        contentForSection.add(getImageAndVideoCard(
            upcomingChallengesContent: challenge, routeForContent: requestedFromRoute, requestedUser: requestedUser));
      });
    }
    return contentForSection.toList();
  }

  //TODO: Update logic to trigger actions depends on contentType and route
  static Widget getImageAndVideoCard(
      {TransformationJourneyUpload transformationJourneyContent,
      TaskSubmission taskSubmissionContent,
      Challenge upcomingChallengesContent,
      ActualProfileRoute routeForContent,
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
        child: ChallengesCard(challenge: upcomingChallengesContent, routeToGo: "/", userRequested: requestedUser),
      );
    }
    return contentForReturn;
  }

  static List<Widget> coachChallengesAndSegments({List<Challenge> challenges, List<CoachSegmentContent> segments}) {
    List<Widget> contentForSection = [];

    if (challenges.length != 0) {
      challenges.forEach((challenge) {
        contentForSection.add(returnCardForChallenge(challenge));
      });
    }

    if (segments.length != 0) {
      segments.forEach((segment) {
        if (segment.completedAt == null) {
          contentForSection.add(returnCardForSegment(segment));
        }
      });
    }
    return contentForSection;
  }

  static Widget returnCardForChallenge(Challenge upcomingChallengesContent) {
    Widget contentForReturn = SizedBox();
    contentForReturn = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: CoachTabChallengeCard(challenge: upcomingChallengesContent),
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

  static List<Widget> getAssessmentCards({List<Task> tasks, List<TaskSubmission> tasksSubmitted}) {
    List<Widget> contentForSection = [];
    tasks.forEach((task) {
      contentForSection.add(returnCardForAssessment(task, tasksSubmitted));
    });
    return contentForSection;
  }

  static Widget returnCardForAssessment(Task task, List<TaskSubmission> tasksSubmitted) {
    return Padding(
        padding: const EdgeInsets.all(5.0), child: CoachAssessmentCard(task: task, assessmentVideos: tasksSubmitted));
  }

  static List<InfoForSegments> segments(List<CourseEnrollment> courseEnrollments) {
    List<InfoForSegments> listOfSegments = [];
    String className;
    String classImage;

    courseEnrollments.forEach((courseEnrollment) {
      courseEnrollment.classes.forEach((classToCheck) {
        className = classToCheck.name;
        classImage = classToCheck.image;
        InfoForSegments infoForSegmentElement =
            InfoForSegments(classImage: classImage, className: className, segments: []);
        classToCheck.segments.forEach((segment) {
          infoForSegmentElement.segments.add(segment);
        });
        listOfSegments.add(infoForSegmentElement);
      });
    });
    return listOfSegments;
  }

  static List<CoachSegmentContent> createSegmentContentInforamtion(List<InfoForSegments> segments) {
    List<CoachSegmentContent> coachSegmentContent = [];

    segments.forEach((segment) {
      segment.segments.forEach((actualSegment) {
        coachSegmentContent.add(CoachSegmentContent(
            segmentId: actualSegment.id,
            classImage: segment.classImage,
            className: segment.className,
            segmentName: actualSegment.name,
            completedAt: actualSegment.completedAt,
            segmentReference: actualSegment.reference,
            isChallenge: actualSegment.is_challenge));
      });
    });
    return coachSegmentContent;
  }
}
