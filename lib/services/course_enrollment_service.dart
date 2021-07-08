import 'package:oluko_app/models/course_enrollment.dart';

class CourseEnrollmentService {
  static int getFirstUncompletedClassIndex(CourseEnrollment courseEnrollment) {
    for (var i = 0; i < courseEnrollment.classes.length; i++) {
      if (courseEnrollment.classes[i].compleatedAt == null) {
        return i;
      }
    }
    return -1;
  }
}
