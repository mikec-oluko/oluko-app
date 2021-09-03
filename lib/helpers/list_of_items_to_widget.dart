import 'package:flutter/material.dart';
import 'package:oluko_app/models/challenge.dart';
import 'package:oluko_app/models/enums/file_type_enum.dart';
import 'package:oluko_app/models/task_submission.dart';
import 'package:oluko_app/models/transformation_journey_uploads.dart';
import 'package:oluko_app/ui/components/challenges_card.dart';
import 'package:oluko_app/ui/components/image_and_video_container.dart';

import 'enum_collection.dart';

class TransformListOfItemsToWidget {
  static List<Widget> getWidgetListFromContent(
      {List<TransformationJourneyUpload> tansformationJourneyData,
      List<TaskSubmission> assessmentVideoData,
      List<Challenge> upcomingChallenges,
      ActualProfileRoute requestedFromRoute}) {
    List<Widget> contentForSection = [];

    if (tansformationJourneyData != null &&
        (assessmentVideoData == null && upcomingChallenges == null)) {
      tansformationJourneyData.forEach((contentUploaded) {
        contentForSection.add(getImageAndVideoCard(
            transformationJourneyContent: contentUploaded,
            routeForContent: requestedFromRoute));
      });
    }

    if (assessmentVideoData != null &&
        (tansformationJourneyData == null && upcomingChallenges == null)) {
      assessmentVideoData.forEach((assessmentVideo) {
        contentForSection.add(getImageAndVideoCard(
            taskSubmissionContent: assessmentVideo,
            routeForContent: requestedFromRoute));
      });
    }

    if (upcomingChallenges != null &&
        (tansformationJourneyData == null && assessmentVideoData == null)) {
      upcomingChallenges.forEach((challenge) {
        contentForSection.add(getImageAndVideoCard(
            upcomingChallengesContent: challenge,
            routeForContent: requestedFromRoute));
      });
    }
    return contentForSection.toList();
  }

  //TODO: Update logic to trigger actions depends on contentType and route
  static Widget getImageAndVideoCard(
      {TransformationJourneyUpload transformationJourneyContent,
      TaskSubmission taskSubmissionContent,
      Challenge upcomingChallengesContent,
      ActualProfileRoute routeForContent}) {
    Widget contentForReturn = SizedBox();

    if (transformationJourneyContent != null) {
      contentForReturn = Padding(
        padding: const EdgeInsets.all(5.0),
        child: ImageAndVideoContainer(
          backgroundImage: transformationJourneyContent.thumbnail,
          isContentVideo:
              transformationJourneyContent.type == FileTypeEnum.video
                  ? true
                  : false,
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
          backgroundImage: taskSubmissionContent.video.thumbUrl != null
              ? taskSubmissionContent.video.thumbUrl
              : '',
          isContentVideo: taskSubmissionContent.video != null,
          videoUrl: taskSubmissionContent.video.url != null
              ? taskSubmissionContent.video.url
              : '',
          originalContent: taskSubmissionContent,
          displayOnViewNamed: routeForContent,
        ),
      );
    }
    if (upcomingChallengesContent != null) {
      contentForReturn = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: ChallengesCard(
            challenge: upcomingChallengesContent, routeToGo: "/"),
      );
    }
    return contentForReturn;
  }
}
