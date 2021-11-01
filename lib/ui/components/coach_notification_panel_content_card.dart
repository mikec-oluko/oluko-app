import 'package:flutter/material.dart';
import 'package:oluko_app/helpers/coach_notification_content.dart';
import 'package:oluko_app/helpers/coach_timeline_content.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/models/coach_timeline_item.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

import '../../routes.dart';
import 'coach_notification_card.dart';
import 'coach_notification_video_card.dart';
import 'coach_timeline_card_content.dart';
import 'coach_timeline_circle_content.dart';
import 'coach_timeline_video_content.dart';

class CoachNotificationPanelContentCard extends StatefulWidget {
  final CoachNotificationContent content;

  const CoachNotificationPanelContentCard({this.content});

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
        return GestureDetector(
          onTap: () => Navigator.pushNamed(context, routeLabels[RouteEnum.courseMarketing],
              arguments: {'course': content.courseContent, 'fromCoach': true}),
          child: Container(
            child: CoachNotificationCard(
              cardImage: content.contentImage,
              cardTitle: content.contentTitle,
              cardSubTitle: content.contentDescription,
              date: content.createdAt != null ? content.createdAt.toDate() : null,
              fileType: CoachFileTypeEnum.recommendedCourse,
            ),
          ),
        );
      case TimelineInteractionType.classes:
        return Container(
          child: CoachTimelineCardContent(
            cardImage: content.contentImage,
            cardTitle: content.contentTitle,
            cardSubTitle: content.contentSubtitle,
            date: content.createdAt != null ? content.createdAt.toDate() : null,
            fileType: CoachFileTypeEnum.recommendedClass,
          ),
        );
      case TimelineInteractionType.segment:
        return Container(
          child: CoachNotificationCard(
              cardImage: content.contentImage,
              cardTitle: content.contentTitle,
              cardSubTitle: content.contentSubtitle,
              date: content.createdAt != null ? content.createdAt.toDate() : null,
              fileType: CoachFileTypeEnum.recommendedSegment),
        );
      case TimelineInteractionType.movement:
        return GestureDetector(
          onTap: () => Navigator.pushNamed(context, routeLabels[RouteEnum.movementIntro],
              arguments: {'movement': content.movementContent}),
          child: Container(
            child: CoachNotificationCard(
                cardImage: content.contentImage,
                cardTitle: content.contentTitle,
                cardSubTitle: '',
                date: content.createdAt != null ? content.createdAt.toDate() : null,
                fileType: CoachFileTypeEnum.recommendedMovement),
          ),
        );
      case TimelineInteractionType.mentoredVideo:
        return Container(
          child: CoachNotificationVideoCard(cardImage: content.contentImage, fileType: CoachFileTypeEnum.mentoredVideo),
        );
      case TimelineInteractionType.sentVideo:
        return Container(
          child: CoachTimelineVideoContent(
              videoThumbnail: content.contentImage,
              videoTitle: content.contentTitle ?? OlukoLocalizations.get(context, 'sentVideo'),
              date: content.createdAt != null ? content.createdAt.toDate() : null,
              fileType: CoachFileTypeEnum.sentVideo),
        );
      //   break;
      default:
    }
  }
}
