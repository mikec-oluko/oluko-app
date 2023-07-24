import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_assignment_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_mentored_videos_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_recommendations_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_request_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_video_message_bloc.dart';
import 'package:oluko_app/helpers/coach_notification_content.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/helpers/video_player_helper.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/coach_notification_card.dart';
import 'package:oluko_app/ui/components/coach_notification_video_card.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class CoachNotificationPanelContentCard extends StatefulWidget {
  final CoachNotificationContent content;
  final String coachId;
  final String userId;

  const CoachNotificationPanelContentCard({this.content, this.coachId, this.userId});

  @override
  _CoachNotificationPanelContentCardState createState() => _CoachNotificationPanelContentCardState();
}

class _CoachNotificationPanelContentCardState extends State<CoachNotificationPanelContentCard> {
  @override
  Widget build(BuildContext context) {
    return getWidgedToUse(widget.content);
  }

  Widget getWidgedToUse(CoachNotificationContent content) {
    switch (content.contentType) {
      case TimelineInteractionType.course:
        return CoachNotificationCard(
            cardImage: content.contentImage,
            cardTitle: content.contentTitle,
            cardSubTitle: content.courseContent.classes.length.toString(),
            cardDescription: content.courseContent.duration,
            date: content.createdAt != null ? content.createdAt.toDate() : Timestamp.now().toDate(),
            fileType: CoachFileTypeEnum.recommendedCourse,
            onCloseCard: () {
              updateRecommendationViewedProperty(content);
            },
            onOpenCard: () {
              Navigator.pushNamed(context, routeLabels[RouteEnum.courseMarketing],
                  arguments: {'course': content.courseContent, 'fromCoach': true, 'isCoachRecommendation': false});
              updateRecommendationViewedProperty(content);
            });
      case TimelineInteractionType.classes:
        return CoachNotificationCard(
          cardImage: content.contentImage,
          cardTitle: content.contentTitle,
          cardSubTitle: content.contentDescription,
          date: content.createdAt != null ? content.createdAt.toDate() : Timestamp.now().toDate(),
          fileType: CoachFileTypeEnum.recommendedClass,
          onCloseCard: () {
            updateRecommendationViewedProperty(content);
          },
          onOpenCard: () {},
        );
      case TimelineInteractionType.segment:
        return CoachNotificationVideoCard(
            cardImage: content.contentImage,
            fileType: CoachFileTypeEnum.sentVideo,
            onCloseCard: () {
              BlocProvider.of<CoachRequestBloc>(context).setRequestSegmentNotificationAsViewed(content.coachRequest.id, widget.userId, true);
            },
            onOpenCard: () {});

      case TimelineInteractionType.movement:
        return CoachNotificationCard(
            cardImage: content.contentImage,
            cardTitle: content.contentTitle,
            cardSubTitle: '',
            date: content.createdAt != null ? content.createdAt.toDate() : Timestamp.now().toDate(),
            fileType: CoachFileTypeEnum.recommendedMovement,
            onCloseCard: () {
              updateRecommendationViewedProperty(content);
            },
            onOpenCard: () {
              Navigator.pushNamed(context, routeLabels[RouteEnum.movementIntro], arguments: {'movement': content.movementContent});
              updateRecommendationViewedProperty(content);
            });
      case TimelineInteractionType.mentoredVideo:
        return CoachNotificationVideoCard(
            cardImage: content.contentImage,
            fileType: CoachFileTypeEnum.mentoredVideo,
            onCloseCard: () {
              updateAnnotationNotificationAsViewed(content);
            },
            onOpenCard: () {
              Navigator.pushNamed(context, routeLabels[RouteEnum.coachShowVideo], arguments: {
                'videoUrl': VideoPlayerHelper.getVideoFromSourceActive(videoHlsUrl: content.mentoredContent.videoHLS, videoUrl: content.videoUrl),
                'aspectRatio': content.mentoredContent.video.aspectRatio,
                'titleForContent': OlukoLocalizations.get(context, 'personalizedVideos')
              });
              updateAnnotationNotificationAsViewed(content);
            });
      case TimelineInteractionType.sentVideo:
        return CoachNotificationVideoCard(
          cardImage: content.contentImage,
          fileType: CoachFileTypeEnum.sentVideo,
          onCloseCard: () {},
          onOpenCard: () {},
        );
      case TimelineInteractionType.messageVideo:
        return CoachNotificationVideoCard(
          cardImage: content.contentImage,
          fileType: CoachFileTypeEnum.messageVideo,
          onCloseCard: () {
            messageVideoAsViewed(content: content, userId: widget.userId);
          },
          onOpenCard: () {
            Navigator.pushNamed(context, routeLabels[RouteEnum.coachShowVideo], arguments: {
              'videoUrl':
                  VideoPlayerHelper.getVideoFromSourceActive(videoHlsUrl: content.coachMediaMessage.videoHls, videoUrl: content.coachMediaMessage.video.url),
              'aspectRatio': content.coachMediaMessage.video.aspectRatio,
              'titleForContent': OlukoLocalizations.of(context).find('coachMessageVideo')
            });
            messageVideoAsViewed(content: content, userId: widget.userId);
          },
        );
      case TimelineInteractionType.recommendedVideo:
        return CoachNotificationVideoCard(
            cardImage: content.contentImage,
            fileType: CoachFileTypeEnum.recommendedVideo,
            onCloseCard: () {
              updateRecommendationViewedProperty(content);
            },
            onOpenCard: () {
              Navigator.pushNamed(context, routeLabels[RouteEnum.coachShowVideo], arguments: {
                'videoUrl': VideoPlayerHelper.getVideoFromSourceActive(
                    videoHlsUrl: content.recommendationMedia.videoHls, videoUrl: content.recommendationMedia.video.url),
                'aspectRatio': content.recommendationMedia.video.aspectRatio,
                'titleForContent': OlukoLocalizations.of(context).find('recommendedVideos')
              });
              updateRecommendationViewedProperty(content);
            });
      case TimelineInteractionType.introductionVideo:
        return CoachNotificationVideoCard(
            cardImage: content.contentImage,
            fileType: CoachFileTypeEnum.introductionVideo,
            onCloseCard: () {
              introductionVideoSeen(content);
            },
            onOpenCard: () {
              Navigator.pushNamed(context, routeLabels[RouteEnum.coachShowVideo], arguments: {
                'videoUrl': VideoPlayerHelper.getVideoFromSourceActive(videoHlsUrl: content.mentoredContent.videoHLS, videoUrl: content.videoUrl),
                'aspectRatio': content.mentoredContent.video.aspectRatio,
                'titleForContent': OlukoLocalizations.get(context, 'personalizedVideos')
              });
              introductionVideoSeen(content);
            });
      default:
        return Container();
    }
  }

  void updateAnnotationNotificationAsViewed(CoachNotificationContent content) {
    BlocProvider.of<CoachMentoredVideosBloc>(context)
        .setMentoredVideoNotificationAsViewed(content.mentoredContent.createdBy, content.mentoredContent.userId, content.mentoredContent.id, true);
  }

  void updateRecommendationViewedProperty(CoachNotificationContent content) {
    BlocProvider.of<CoachRecommendationsBloc>(context).setRecommendationNotificationAsViewed(
        content.coachRecommendation.id, content.coachRecommendation.originUserId, content.coachRecommendation.destinationUserId, true);
  }

  void introductionVideoSeen(CoachNotificationContent content) {
    BlocProvider.of<CoachAssignmentBloc>(context).introductionVideoAsSeen(content.mentoredContent.userId);
  }

  void messageVideoAsViewed({CoachNotificationContent content, String userId}) {
    BlocProvider.of<CoachVideoMessageBloc>(context).markVideoMessageNotificationAsSeen(userId: userId, messageVideoContent: content.coachMediaMessage);
  }
}
