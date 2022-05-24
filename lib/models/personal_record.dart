import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/base.dart';
import 'package:oluko_app/models/enums/personal_record_param.dart';

class PersonalRecord extends Base {
  String challengeId;
  DocumentReference challengeReference;
  String courseImage;
  String userId;
  int value;
  PersonalRecordParam parameter;
  String courseEnrollmentId;
  DocumentReference courseEnrollmentReference;
  String segmentImage;
  bool doneFromProfile;

  PersonalRecord(
      {this.challengeId,
      this.challengeReference,
      this.courseImage,
      this.userId,
      this.value,
      this.parameter,
      this.courseEnrollmentId,
      this.courseEnrollmentReference,
      this.segmentImage,
      this.doneFromProfile,
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

  factory PersonalRecord.fromJson(Map<String, dynamic> json) {
    PersonalRecord personalRecord = PersonalRecord(
        challengeId: json['challenge_id']?.toString(),
        challengeReference: json['challenge_reference'] as DocumentReference,
        courseImage: json['course_image'] as String,
        segmentImage: json['segment_image'] as String,
        doneFromProfile: json['donde_from_profile'] as bool,
        userId: json['user_id']?.toString(),
        value: json['value'] as int,
        parameter: json['parameter'] == null ? null : PersonalRecordParam.values[json['parameter'] as int],
        courseEnrollmentId: json['course_enrollment_id']?.toString(),
        courseEnrollmentReference: json['course_enrollment_reference'] as DocumentReference);
    personalRecord.setBase(json);
    return personalRecord;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> personalRecordJson = {
      'challenge_id': challengeId,
      'challenge_reference': challengeReference,
      'course_image': courseImage,
      'segment_image': segmentImage,
      'donde_from_profile': doneFromProfile,
      'user_id': userId,
      'value': value,
      'parameter': parameter == null ? null : parameter.index,
      'course_enrollment_id': courseEnrollmentId,
      'course_enrollment_reference': courseEnrollmentReference
    };
    personalRecordJson.addEntries(super.toJson().entries);
    return personalRecordJson;
  }
}
