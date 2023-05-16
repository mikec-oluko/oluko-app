import 'package:cloud_firestore/cloud_firestore.dart';

class WeightRecord {
  String courseEnrollmentId, classId, movementId, segmentId;
  int sectionIndex;
  double weight;
  Timestamp createdAt;
  WeightRecord({this.courseEnrollmentId, this.classId, this.movementId, this.segmentId, this.sectionIndex, this.weight, this.createdAt});

  factory WeightRecord.fromJson(Map<String, dynamic> json) {
    WeightRecord weightRecord = WeightRecord(
      courseEnrollmentId: json['course_enrollment_id']?.toString(),
      classId: json['class_id']?.toString(),
      movementId: json['id']?.toString(),
      segmentId: json['segment_id']?.toString(),
      sectionIndex: json['section_index'] as int,
      weight: json['weight'] is int ? double.parse(json['weight'].toString()) : json['weight'] as double,
      createdAt: json['created_at'] as Timestamp,
    );
    return weightRecord;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> weightRecord = {
      'course_enrollment_id': courseEnrollmentId,
      'class_id': classId,
      'id': movementId,
      'segment_id': segmentId,
      'section_index': sectionIndex,
      'weight': double.parse(weight.toString()),
      'created_at': createdAt,
    };
    return weightRecord;
  }
}
