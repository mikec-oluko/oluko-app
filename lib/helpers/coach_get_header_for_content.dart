import 'package:flutter/material.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'enum_collection.dart';

class CoachHeders {
  static String getContentHeader({BuildContext context, CoachFileTypeEnum fileType}) {
    switch (fileType) {
      case CoachFileTypeEnum.mentoredVideo:
        return OlukoLocalizations.of(context).find('timelinePersonalizedVideo');
      case CoachFileTypeEnum.introductionVideo:
        return OlukoLocalizations.of(context).find('timelineIntroductionVideo');
      case CoachFileTypeEnum.sentVideo:
        return OlukoLocalizations.of(context).find('timelineSentVideo');
      case CoachFileTypeEnum.recommendedCourse:
        return OlukoLocalizations.of(context).find('timelineRecommendedCourse');
      case CoachFileTypeEnum.recommendedClass:
        return OlukoLocalizations.of(context).find('timelineRecommendedClass');
      case CoachFileTypeEnum.recommendedMovement:
        return OlukoLocalizations.of(context).find('timelineRecommendedMovement');
      case CoachFileTypeEnum.recommendedSegment:
        return OlukoLocalizations.of(context).find('notificationSegment');
      case CoachFileTypeEnum.faqVideo:
        return OlukoLocalizations.of(context).find('timelineFaqVideo');
      case CoachFileTypeEnum.recommendedVideo:
        return OlukoLocalizations.of(context).find('timelineRecommendedVideos');
      case CoachFileTypeEnum.messageVideo:
        return OlukoLocalizations.of(context).find('timelineCoachMessageVideo');
      case CoachFileTypeEnum.welcomeVideo:
        return OlukoLocalizations.of(context).find('timelineWelcomeVideo');
    }
    return '';
  }
}
