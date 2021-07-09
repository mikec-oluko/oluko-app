import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/challenge.dart';
import 'package:oluko_app/models/submodels/enrollment_class.dart';
import 'base.dart';

class CourseEnrollment extends Base {
  String userId;
  DocumentReference userReference;
  String courseId;
  DocumentReference courseReference;
  int completion;
  Timestamp completedAt;
  Timestamp finishedAt;
  List<EnrollmentClass> classes;
  List<Challenge> challenges;

  CourseEnrollment(
      {this.userId,
      this.userReference,
      this.courseId,
      this.courseReference,
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
        userId: json['user_id'],
        userReference: json['user_reference'],
        courseId: json['course_id'],
        courseReference: json['course_reference'],
        completion: json['completion'],
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
      'user_id': userId,
      'user_reference': userReference,
      'course_id': courseId,
      'course_reference': courseReference,
      'completion': completion,
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
