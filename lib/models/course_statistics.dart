import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mvt_fitness/models/base.dart';

class CourseStatistics extends Base {
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
        courseId: json['course_id'],
        courseReference: json['course_reference'],
        doing: json['doing'],
        takingUp: json['taking_up'],
        completionRate: json['completion_rate'],
        completed: json['completed']);
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
}
