import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/base.dart';
import 'package:oluko_app/models/submodels/audio.dart';
import 'package:oluko_app/models/submodels/class_audio.dart';
import 'package:oluko_app/models/submodels/object_submodel.dart';

class EnrollmentAudio extends Base {
  ObjectSubmodel course;
  ObjectSubmodel classCourse;
  ObjectSubmodel enrollmentCourse;
  List<Audio> audios;
  
  EnrollmentAudio(
      {this.course,
      this.classCourse,
      this.audios,
      this.enrollmentCourse,
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
      course: json['course'] != null ? ObjectSubmodel.fromJson(json['course'] as Map<String, dynamic>) : null,
      classCourse: json['class_course'] != null ? ObjectSubmodel.fromJson(json['class_course'] as Map<String, dynamic>) : null,
      enrollmentCourse: json['enrollment_course'] != null ? ObjectSubmodel.fromJson(json['enrollment_course'] as Map<String, dynamic>) : null,
      audios: List<Audio>.from((json['audios'] as Iterable).map((audio) => Audio.fromJson(audio as Map<String, dynamic>))),
    );
    enrollmentAudio.setBase(json);
    return enrollmentAudio;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> enrollmentAudio = {
      'course': course,
      'class_course': classCourse,
      'audios': audios == null ? null : List<Audio>.from(audios.map((classAudio) => classAudio.toJson())),
      'enrollment_course': enrollmentCourse,
    };
    enrollmentAudio.addEntries(super.toJson().entries);
    return enrollmentAudio;
  }
}