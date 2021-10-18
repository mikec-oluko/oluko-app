import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/base.dart';

class Challenge extends Base {
  String segmentId;
  DocumentReference segmentReference;
  String courseEnrollmentId;
  DocumentReference courseEnrollmentReference;
  String classId;
  DocumentReference classReference;
  Timestamp completedAt;
  List<String> requiredClasses;
  List<String> requiredSegments;
  int index;
  String challengeType;
  String result;
  String image;
  String challengeName;

  Challenge(
      {this.segmentId,
      this.segmentReference,
      this.courseEnrollmentId,
      this.courseEnrollmentReference,
      this.classId,
      this.classReference,
      this.completedAt,
      this.requiredClasses,
      this.requiredSegments,
      this.index,
      this.challengeType,
      this.result,
      this.image,
      this.challengeName,
      String id,
      Timestamp createdAt,
      String createdBy,
      Timestamp updatedAt,
      String updatedBy,
      bool isHidden,
      bool isDeleted})
      : super(
            id: id,
            createdBy: createdBy,
            createdAt: createdAt,
            updatedAt: updatedAt,
            updatedBy: updatedBy,
            isDeleted: isDeleted,
            isHidden: isHidden);

  factory Challenge.fromJson(Map<String, dynamic> json) {
    Challenge challengeObject = Challenge(
        segmentId: json['segment_id']?.toString(),
        segmentReference: json['segment_reference'] as DocumentReference,
        courseEnrollmentId: json['course_enrollment_id']?.toString(),
        courseEnrollmentReference:
            json['course_enrollment_reference'] as DocumentReference,
        classId: json['class_id']?.toString(),
        classReference: json['class_reference'] as DocumentReference,
        result: json['result']?.toString(),
        completedAt: json['completed_at'] as Timestamp,
        requiredClasses: json['required_classes'] != null
            ? (json['required_classes'] as Iterable)
                .map<String>((reqClass) => reqClass.toString())
                .toList()
            : [],
        requiredSegments: json['required_segments'] != null
            ? (json['required_segments'] as Iterable)
                .map<String>((reqClass) => reqClass.toString())
                .toList()
            : [],
        index: json['index'] as int,
        challengeType: json['type']?.toString(),
        image: json['image']?.toString(),
        challengeName: json['name']?.toString());

    challengeObject.setBase(json);
    return challengeObject;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> challengeJson = {
      'segment_id': segmentId,
      'segment_reference': segmentReference,
      'course_enrollment_id': courseEnrollmentId,
      'course_enrollment_reference': courseEnrollmentReference,
      'class_id': classId,
      'class_reference': classReference,
      'result': result,
      'completed_at': completedAt,
      'required_classes': requiredClasses,
      'required_segments': requiredSegments,
      'index': index,
      'type': challengeType,
      'image': image,
      'name': challengeName,
    };
    challengeJson.addEntries(super.toJson().entries);
    return challengeJson;
  }
}
