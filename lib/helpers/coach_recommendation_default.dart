import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/annotation.dart';
import 'package:oluko_app/models/class.dart';
import 'package:oluko_app/models/coach_request.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/movement.dart';
import 'package:oluko_app/models/recommendation.dart';
import 'package:oluko_app/models/segment.dart';

class CoachRecommendationDefault extends CoachRecommendationExtra {
  Recommendation coachRecommendation;
  String contentTitle, contentSubtitle, contentImage, contentDescription;
  num contentTypeIndex;
  Timestamp createdAt;
  CoachRecommendationDefault(
      {this.coachRecommendation,
      this.contentTitle,
      this.contentSubtitle,
      this.contentImage,
      this.contentDescription,
      this.contentTypeIndex,
      this.createdAt,
      Class classContent,
      Segment segmentContent,
      CoachRequest coachRequest,
      Movement movementContent,
      Annotation mentoredContent,
      Course courseContent})
      : super(
            classContent: classContent,
            segmentContent: segmentContent,
            coachRequest: coachRequest,
            movementContent: movementContent,
            mentoredContent: mentoredContent,
            courseContent: courseContent);
}

class CoachRecommendationExtra {
  Class classContent;
  Segment segmentContent;
  CoachRequest coachRequest;
  Movement movementContent;
  Annotation mentoredContent;
  Course courseContent;

  CoachRecommendationExtra(
      {this.classContent,
      this.segmentContent,
      this.coachRequest,
      this.movementContent,
      this.mentoredContent,
      this.courseContent});
}
