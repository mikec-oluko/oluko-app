import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/helpers/coach_recommendation_default.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/models/annotation.dart';
import 'package:oluko_app/models/class.dart';
import 'package:oluko_app/models/coach_media_message.dart';
import 'package:oluko_app/models/coach_request.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/movement.dart';
import 'package:oluko_app/models/recommendation.dart';
import 'package:oluko_app/models/recommendation_media.dart';
import 'package:oluko_app/models/segment.dart';

class CoachNotificationContent extends CoachRecommendationDefault {
  String videoUrl;
  CoachNotificationContent(
      {Recommendation coachRecommendation,
      String contentTitle,
      String contentSubtitle,
      String contentImage,
      String contentDescription,
      TimelineInteractionType contentType,
      Timestamp createdAt,
      Class classContent,
      Segment segmentContent,
      CoachRequest coachRequest,
      Movement movementContent,
      Annotation mentoredContent,
      RecommendationMedia recommendationMediaContent,
      Course courseContent,
      CoachMediaMessage coachMediaMessage,
      this.videoUrl})
      : super(
            coachRecommendation: coachRecommendation,
            contentTitle: contentTitle,
            contentSubtitle: contentSubtitle,
            contentImage: contentImage,
            contentDescription: contentDescription,
            contentType: contentType,
            createdAt: createdAt,
            classContent: classContent,
            segmentContent: segmentContent,
            coachRequest: coachRequest,
            movementContent: movementContent,
            mentoredContent: mentoredContent,
            recommendationMedia: recommendationMediaContent,
            courseContent: courseContent,
            coachMediaMessage: coachMediaMessage);
}
