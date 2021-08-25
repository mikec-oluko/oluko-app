import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/challenge.dart';
import 'package:oluko_app/models/submodels/enrollment_class.dart';
import 'package:oluko_app/models/submodels/object_submodel.dart';
import 'base.dart';

class CourseEnrollment extends Base {
  DocumentReference userReference;
  ObjectSubmodel course;
  double completion;
  Timestamp completedAt;
  Timestamp finishedAt;
  List<EnrollmentClass> classes;
  List<Challenge> challenges;

  CourseEnrollment(
      {this.userReference,
      this.course,
      this.completion,
      this.completedAt,
      this.finishedAt,
      this.classes,
      this.challenges,
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

  factory CourseEnrollment.fromJson(Map<String, dynamic> json) {
    CourseEnrollment courseEnrollment = CourseEnrollment(
        userReference: json['user_reference'],
        course: ObjectSubmodel.fromJson(json['course']),
        completion:
            json['completion'] == null ? 0.0 : (json['completion']).toDouble(),
        completedAt: json['completed_at'],
        finishedAt: json['finished_at'],
        classes: json['classes'] != null
            ? List<EnrollmentClass>.from(
                json['classes'].map((c) => EnrollmentClass.fromJson(c)))
            : null,
        challenges: json['challenges'] != null
            ? List<Challenge>.from(
                json['challenges'].map((c) => Challenge.fromJson(c)))
            : null);
    courseEnrollment.setBase(json);
    return courseEnrollment;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> courseEnrollmentJson = {
      'user_reference': userReference,
      'completion': completion == null ? 0.0 : completion.toDouble(),
      'course': course.toJson(),
      'completed_at': completedAt,
      'finished_at': finishedAt,
      'classes': classes == null
          ? null
          : List<dynamic>.from(classes.map((c) => c.toJson())),
      'challenges': challenges == null
          ? null
          : List<dynamic>.from(challenges.map((c) => c.toJson())),
    };
    courseEnrollmentJson.addEntries(super.toJson().entries);
    return courseEnrollmentJson;
  }
}
