import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/coach_request.dart';

class CoachSegmentContent {
  String segmentId;
  String className;
  String classImage;
  String segmentName;
  bool isChallenge;
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
      this.isChallenge});
}
