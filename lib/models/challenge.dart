import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/base.dart';
import 'package:oluko_app/models/submodels/audio.dart';
import 'package:oluko_app/models/submodels/user_submodel.dart';

class Challenge extends Base {
  String segmentId; 
  DocumentReference segmentReference;
  String courseEnrollmentId;
  DocumentReference courseEnrollmentReference;
  String classId;
  DocumentReference classReference;
  Timestamp completedAt;
  List<dynamic> requiredClasses;
  List<dynamic> requiredSegments;
  String result;
  String image; 
  UserSubmodel user;
  List<Audio> audios;
  int indexSegment;
  int indexClass;
  bool isActive;

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
      this.indexSegment,
      this.indexClass,
      this.result,
      this.image,
      this.user,
      this.isActive,
      this.audios,
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
      courseEnrollmentReference: json['course_enrollment_reference'] as DocumentReference,
      classId: json['class_id']?.toString(),
      classReference: json['class_reference'] as DocumentReference,
      result: json['result']?.toString(),
      completedAt: json['completed_at'] as Timestamp,
      requiredClasses: json['required_classes'] != null
          ? (json['required_classes'] as Iterable).map<String>((reqClass) => reqClass.toString()).toList()
          : [],
      requiredSegments: json['required_segments'] != null
          ? (json['required_segments'] as Iterable).map<String>((reqClass) => reqClass.toString()).toList()
          : [],
      audios: json['audios'] != null
          ? List<Audio>.from((json['audios'] as Iterable).map((audio) => Audio.fromJson(audio as Map<String, dynamic>)))
          : null,
      image: json['image']?.toString(),
      user: UserSubmodel.fromJson(json['user'] as Map<String, dynamic>),
      indexSegment: json['index_segment'] as int,
      indexClass: json['index_class'] as int,
      isActive:json['is_active']as bool,
    );

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
      'image': image,
      'audios': audios == null ? null : List<dynamic>.from(audios.map((audio) => audio.toJson())),
      'user': user.toJson()
    };
    challengeJson.addEntries(super.toJson().entries);
    return challengeJson;
  }
}
