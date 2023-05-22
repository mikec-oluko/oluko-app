import 'package:oluko_app/models/course_enrollment.dart';

class WorkoutSchedule {
  DateTime scheduledDate;
  DateTime enrolledDate;
  String className;
  int classIndex;
  String day;
  CourseEnrollment courseEnrollment;

  WorkoutSchedule({this.className, this.classIndex, this.scheduledDate, this.enrolledDate, this.day, this.courseEnrollment});
}
