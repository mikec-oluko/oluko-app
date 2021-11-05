import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_mentored_videos_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_recommendations_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_request_bloc.dart';
import 'package:oluko_app/helpers/coach_notification_content.dart';
import 'package:oluko_app/helpers/coach_timeline_content.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import '../../routes.dart';
import 'coach_notification_card.dart';
import 'coach_notification_video_card.dart';

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
    switch (TimelineContentOption.getTimelineOption(content.contentTypeIndex as int)) {
      case TimelineInteractionType.course:
        return CoachNotificationCard(
          cardImage: content.contentImage,
          cardTitle: content.contentTitle,
          cardSubTitle: content.courseContent.classes.length.toString(),
          date: content.createdAt != null ? content.createdAt.toDate() : null,
          fileType: CoachFileTypeEnum.recommendedCourse,
          onCloseCard: () {
            BlocProvider.of<CoachRecommendationsBloc>(context).setRecommendationNotificationAsViewed(
                content.coachRecommendation.id,
                content.coachRecommendation.originUserId,
                content.coachRecommendation.destinationUserId,
                true);
          },
          onOpenCard: () {},
        );
      case TimelineInteractionType.classes:
        return CoachNotificationCard(
          cardImage: content.contentImage,
          cardTitle: content.contentTitle,
          cardSubTitle: content.contentDescription,
          date: content.createdAt != null ? content.createdAt.toDate() : null,
          fileType: CoachFileTypeEnum.recommendedClass,
          onCloseCard: () {
            BlocProvider.of<CoachRecommendationsBloc>(context).setRecommendationNotificationAsViewed(
                content.coachRecommendation.id,
                content.coachRecommendation.originUserId,
                content.coachRecommendation.destinationUserId,
                true);
          },
          onOpenCard: () {},
        );
      case TimelineInteractionType.segment:
        return CoachNotificationCard(
            cardImage: content.contentImage,
            cardTitle: content.contentTitle,
            cardSubTitle: content.contentSubtitle,
            date: content.createdAt != null ? content.createdAt.toDate() : null,
            fileType: CoachFileTypeEnum.recommendedSegment,
            onCloseCard: () {
              //TODO: GET NOTIFICATIONSTATUS AND USERID
              BlocProvider.of<CoachRequestBloc>(context)
                  .setRequestSegmentNotificationAsViewed(content.coachRequest.id, content.coachRequest.coachId, true);
            },
            onOpenCard: () {});
      case TimelineInteractionType.movement:
        return CoachNotificationCard(
            cardImage: content.contentImage,
            cardTitle: content.contentTitle,
            cardSubTitle: '',
            date: content.createdAt != null ? content.createdAt.toDate() : null,
            fileType: CoachFileTypeEnum.recommendedMovement,
            onCloseCard: () {
              BlocProvider.of<CoachRecommendationsBloc>(context).setRecommendationNotificationAsViewed(
                  content.coachRecommendation.id,
                  content.coachRecommendation.originUserId,
                  content.coachRecommendation.destinationUserId,
                  true);
            },
            onOpenCard: () {});
      case TimelineInteractionType.mentoredVideo:
        return CoachNotificationVideoCard(
          cardImage: content.contentImage,
          fileType: CoachFileTypeEnum.mentoredVideo,
          onCloseCard: () {
            BlocProvider.of<CoachMentoredVideosBloc>(context).setMentoredVideoNotificationAsViewed(
                content.mentoredContent.createdBy, content.mentoredContent.userId, content.mentoredContent.id, true);
          },
          onOpenCard: () {},
        );
      case TimelineInteractionType.sentVideo:
        return CoachNotificationVideoCard(
          cardImage: content.contentImage,
          fileType: CoachFileTypeEnum.sentVideo,
          onCloseCard: () {},
          onOpenCard: () {},
        );
      //   break;
      default:
    }
  }
}
