import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/base.dart';

class EnrollmentSegment extends Base {
  String segmentId;
  DocumentReference segmentReference;
  String segmentName;
  Timestamp compleatedAt;

  EnrollmentSegment(
      {this.segmentId,
      this.segmentReference,
      this.segmentName,
      this.compleatedAt});

  factory EnrollmentSegment.fromJson(Map<String, dynamic> json) {
    return EnrollmentSegment(
        segmentId: json['segment_id'],
        segmentReference: json['segment_reference'],
        segmentName: json['segment_name'],
        compleatedAt: json['compleated_at']);
  }

  Map<String, dynamic> toJson() => {
        'segment_id': segmentId,
        'segment_reference': segmentReference,
        'segment_name': segmentName,
        'compleated_at': compleatedAt
      };
}
