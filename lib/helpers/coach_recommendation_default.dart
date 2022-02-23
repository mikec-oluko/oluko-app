import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/models/annotation.dart';
import 'package:oluko_app/models/class.dart';
import 'package:oluko_app/models/coach_request.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/movement.dart';
import 'package:oluko_app/models/recommendation.dart';
import 'package:oluko_app/models/recommendation_media.dart';
import 'package:oluko_app/models/segment.dart';

class CoachRecommendationDefault extends CoachRecommendationExtra {
  Recommendation coachRecommendation;
  String contentTitle, contentSubtitle, contentImage, contentDescription;
  TimelineInteractionType contentType;
  Timestamp createdAt;
  CoachRecommendationDefault({
    this.coachRecommendation,
    this.contentTitle,
    this.contentSubtitle,
    this.contentImage,
    this.contentDescription,
    this.contentType,
    this.createdAt,
    Class classContent,
    Segment segmentContent,
    CoachRequest coachRequest,
    Movement movementContent,
    Annotation mentoredContent,
    RecommendationMedia recommendationMedia,
    Course courseContent,
  }) : super(
          classContent: classContent,
          segmentContent: segmentContent,
          coachRequest: coachRequest,
          movementContent: movementContent,
          mentoredContent: mentoredContent,
          courseContent: courseContent,
          recommendationMedia: recommendationMedia,
        );
}

class CoachRecommendationExtra {
  Class classContent;
  Segment segmentContent;
  CoachRequest coachRequest;
  Movement movementContent;
  Annotation mentoredContent;
  Course courseContent;
  RecommendationMedia recommendationMedia;

  CoachRecommendationExtra(
      {this.classContent,
      this.segmentContent,
      this.coachRequest,
      this.movementContent,
      this.mentoredContent,
      this.courseContent,
      this.recommendationMedia});
}
