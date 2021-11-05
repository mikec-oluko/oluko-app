import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/helpers/coach_recommendation_default.dart';
import 'package:oluko_app/models/annotation.dart';
import 'package:oluko_app/models/class.dart';
import 'package:oluko_app/models/coach_request.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/movement.dart';
import 'package:oluko_app/models/recommendation.dart';
import 'package:oluko_app/models/segment.dart';

class CoachNotificationContent extends CoachRecommendationDefault {
  String videoUrl;
  CoachNotificationContent(
      {Recommendation coachRecommendation,
      String contentTitle,
      String contentSubtitle,
      String contentImage,
      String contentDescription,
      num contentTypeIndex,
      Timestamp createdAt,
      Class classContent,
      Segment segmentContent,
      CoachRequest coachRequest,
      Movement movementContent,
      Annotation mentoredContent,
      Course courseContent,
      this.videoUrl})
      : super(
            coachRecommendation: coachRecommendation,
            contentTitle: contentTitle,
            contentSubtitle: contentSubtitle,
            contentImage: contentImage,
            contentDescription: contentDescription,
            contentTypeIndex: contentTypeIndex,
            createdAt: createdAt,
            classContent: classContent,
            segmentContent: segmentContent,
            coachRequest: coachRequest,
            movementContent: movementContent,
            mentoredContent: mentoredContent,
            courseContent: courseContent);
}
