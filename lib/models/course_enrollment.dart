import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/challenge.dart';
import 'package:oluko_app/models/submodels/enrollment_class.dart';
import 'package:oluko_app/models/submodels/object_submodel.dart';
import 'base.dart';

class CourseEnrollment extends Base {
  DocumentReference userReference;
  String userId;
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
      this.userId,
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
        userReference: json['user_reference'] as DocumentReference,
        userId: json['user_id'] as String,
        course: json['course'] != null
            ? ObjectSubmodel.fromJson(json['course'] as Map<String, dynamic>)
            : null,
        completion: json['completion'] == null || json['completion'] == 0
            ? 0.0
            : json['completion'].toString() == '1'
                ? ((json['completion'] as int).toDouble())
                : json['completion'] as double,
        completedAt: json['completed_at'] as Timestamp,
        finishedAt: json['finished_at'] as Timestamp,
        classes: json['classes'] != null
            ? List<EnrollmentClass>.from((json['classes'] as Iterable).map(
                (c) => EnrollmentClass.fromJson(c as Map<String, dynamic>)))
            : null,
        challenges: json['challenges'] != null
            ? List<Challenge>.from((json['challenges'] as Iterable)
                .map((c) => Challenge.fromJson(c as Map<String, dynamic>)))
            : null);
    courseEnrollment.setBase(json);
    return courseEnrollment;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> courseEnrollmentJson = {
      'user_reference': userReference,
      'user_id': userId,
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
