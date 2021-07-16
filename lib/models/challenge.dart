import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mvt_fitness/models/base.dart';

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
  String challengeImage;
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
      this.challengeImage,
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
        segmentId: json['segment_id'],
        segmentReference: json['segment_reference'],
        courseEnrollmentId: json['course_enrollment_id'],
        courseEnrollmentReference: json['course_enrollment_reference'],
        classId: json['class_id'],
        classReference: json['class_reference'],
        result: json['result'],
        completedAt: json['completed_at'],
        requiredClasses: json['required_classes'],
        requiredSegments: json['required_segments'],
        index: json['index'],
        challengeType: json['challenge_type'],
        challengeImage: json['challenge_image'],
        challengeName: json['challenge_name']);

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
      'challenge_type': challengeType,
      'challenge_image': challengeImage,
      'challenge_name': challengeName,
    };
    challengeJson.addEntries(super.toJson().entries);
    return challengeJson;
  }
}
