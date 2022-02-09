import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/coach_request.dart';
import 'package:oluko_app/models/course_enrollment.dart';

class CoachSegmentContent {
  String segmentId;
  String className;
  String classImage;
  String segmentName;
  bool isChallenge;
  int indexClass, indexSegment, indexCourse;
  CourseEnrollment courseEnrollment;
  Timestamp completedAt;
  Timestamp createdAt;
  DocumentReference segmentReference;
  CoachRequest coachRequest;
  CoachSegmentContent(
      {this.segmentId,
      this.classImage,
      this.className,
      this.segmentName,
      this.completedAt,
      this.createdAt,
      this.segmentReference,
      this.coachRequest,
      this.isChallenge,
      this.indexClass,
      this.indexCourse,
      this.indexSegment,
      this.courseEnrollment});
}
