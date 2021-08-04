import 'package:flutter/material.dart';
import 'package:oluko_app/models/challenge.dart';
import 'package:oluko_app/models/enums/file_type_enum.dart';
import 'package:oluko_app/models/task_submission.dart';
import 'package:oluko_app/models/transformation_journey_uploads.dart';
import 'package:oluko_app/ui/components/image_and_video_container.dart';

class TransformListOfItemsToWidget {
  static List<Widget> getWidgetListFromContent(
      {List<TransformationJourneyUpload> tansformationJourneyData,
      List<TaskSubmission> assessmentVideoData,
      List<Challenge> upcomingChallenges}) {
    List<Widget> contentForSection = [];

    if (tansformationJourneyData != null &&
        (assessmentVideoData == null && upcomingChallenges == null)) {
      tansformationJourneyData.forEach((contentUploaded) {
        contentForSection.add(getImageAndVideoCard(
            transformationJourneyContent: contentUploaded));
      });
    }

    if (assessmentVideoData != null &&
        (tansformationJourneyData == null && upcomingChallenges == null)) {
      assessmentVideoData.forEach((assessmentVideo) {
        contentForSection
            .add(getImageAndVideoCard(taskSubmissionContent: assessmentVideo));
      });
    }

    if (upcomingChallenges != null &&
        (tansformationJourneyData == null && assessmentVideoData == null)) {
      upcomingChallenges.forEach((challenge) {
        contentForSection
            .add(getImageAndVideoCard(upcomingChallengesContent: challenge));
      });
    }
    return contentForSection.toList();
  }

  //TODO: Update logic to trigger actions depends on contentType and route
  static Widget getImageAndVideoCard(
      {TransformationJourneyUpload transformationJourneyContent,
      TaskSubmission taskSubmissionContent,
      Challenge upcomingChallengesContent}) {
    Widget contentForReturn = SizedBox();

    if (transformationJourneyContent != null) {
      contentForReturn = ImageAndVideoContainer(
        backgroundImage: transformationJourneyContent.thumbnail,
        isContentVideo: transformationJourneyContent.type == FileTypeEnum.video
            ? true
            : false,
        videoUrl: transformationJourneyContent.file,
        originalContent: transformationJourneyContent,
      );
    }
    if (taskSubmissionContent != null && taskSubmissionContent.video != null) {
      contentForReturn = ImageAndVideoContainer(
        backgroundImage: taskSubmissionContent.video.thumbUrl != null
            ? taskSubmissionContent.video.thumbUrl
            : '',
        isContentVideo: taskSubmissionContent.video != null,
        videoUrl: taskSubmissionContent.video.url != null
            ? taskSubmissionContent.video.url
            : '',
        originalContent: taskSubmissionContent,
      );
    }
    if (upcomingChallengesContent != null) {
      //TODO: Crear container con locker icon and w/ also style
      contentForReturn = ImageAndVideoContainer(
        backgroundImage: upcomingChallengesContent.challengeImage,
        isContentVideo: false,
        originalContent: upcomingChallengesContent,
      );
    }

    return contentForReturn;
  }
}
