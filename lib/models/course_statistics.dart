import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:oluko_app/models/base.dart';

class CourseStatistics extends Base with EquatableMixin {
  String courseId;
  DocumentReference courseReference;
  int doing;
  int takingUp;
  int completionRate;
  int completed;

  CourseStatistics(
      {this.courseId,
      this.doing,
      this.takingUp,
      this.completionRate,
      this.completed,
      this.courseReference,
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

  factory CourseStatistics.fromJson(Map<String, dynamic> json) {
    CourseStatistics movement = CourseStatistics(
        courseId: json['course_id']?.toString(),
        courseReference: json['course_reference'] as DocumentReference,
        doing: json['doing'] as int,
        takingUp: json['taking_up'] as int,
        completionRate: json['completion_rate'] as int,
        completed: json['completed'] as int);
    movement.setBase(json);
    return movement;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> courseStatisticsJson = {
      'course_id': courseId,
      'course_reference': courseReference,
      'doing': doing,
      'taking_up': takingUp,
      'completion_rate': completionRate,
      'completed': completed,
    };
    courseStatisticsJson.addEntries(super.toJson().entries);
    return courseStatisticsJson;
  }

  @override
  List<Object> get props => [
        courseId,
        doing,
        takingUp,
        completionRate,
        completed,
        courseReference,
        id,
        createdBy,
        createdAt,
        updatedAt,
        updatedBy,
        isDeleted,
        isHidden
      ];
}
