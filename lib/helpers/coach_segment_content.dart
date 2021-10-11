import 'package:cloud_firestore/cloud_firestore.dart';

class CoachSegmentContent {
  String segmentId;
  String className;
  String classImage;
  String segmentName;
  Timestamp compleatedAt;
  DocumentReference segmentReference;
  CoachSegmentContent(
      {this.segmentId, this.classImage, this.className, this.segmentName, this.compleatedAt, this.segmentReference});
}
