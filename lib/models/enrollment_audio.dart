import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/base.dart';
import 'package:oluko_app/models/submodels/class_audio.dart';

class EnrollmentAudio extends Base {
  DocumentReference courseEnrollmentReference;
  String courseEnorllmentId;
  List<ClassAudio> classAudios;

  EnrollmentAudio(
      {this.courseEnrollmentReference,
      this.courseEnorllmentId,
      this.classAudios,
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

  factory EnrollmentAudio.fromJson(Map<String, dynamic> json) {
    EnrollmentAudio enrollmentAudio = EnrollmentAudio(
      courseEnorllmentId: json['course_enrollment_id']?.toString(),
      courseEnrollmentReference: json['course_enrollment_reference'] as DocumentReference,
      classAudios: json['class_audios'] == null
          ? null
          : List<ClassAudio>.from(
              (json['class_audios'] as Iterable).map((classAudio) => ClassAudio.fromJson(classAudio as Map<String, dynamic>))),
    );
    enrollmentAudio.setBase(json);
    return enrollmentAudio;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> enrollmentAudio = {
      'course_enorllment_id': courseEnorllmentId,
      'course_enrollment_reference': courseEnrollmentReference,
      'class_audios': classAudios == null ? null : List<ClassAudio>.from(classAudios.map((classAudio) => classAudio.toJson()))
    };
    enrollmentAudio.addEntries(super.toJson().entries);
    return enrollmentAudio;
  }
}
