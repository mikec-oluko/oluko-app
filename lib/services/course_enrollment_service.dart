import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/submodels/enrollment_class.dart';
import 'package:oluko_app/models/submodels/enrollment_segment.dart';

class CourseEnrollmentService {
  static int getFirstUncompletedClassIndex(CourseEnrollment courseEnrollment) {
    for (var i = 0; i < courseEnrollment.classes.length; i++) {
      if (courseEnrollment.classes[i].completedAt == null) {
        return i;
      }
    }
    return -1;
  }

  static int getFirstUncompletedSegmentIndex(EnrollmentClass enrollmentClass) {
    for (var i = 0; i < enrollmentClass.segments.length; i++) {
      if (enrollmentClass.segments[i].completedAt == null) {
        return i;
      }
    }
    return -1;
  }

  static double getClassProgress(CourseEnrollment courseEnrollment, int classIndex) {
    if (courseEnrollment == null) {
      return 0;
    }
    int segmentsCompleted = 0;
    EnrollmentClass enrollmentClass = courseEnrollment.classes[classIndex];
    List<EnrollmentSegment> segments = enrollmentClass.segments;
    for (var i = 0; i < segments.length; i++) {
      if (segments[i].completedAt != null) {
        segmentsCompleted++;
      }
    }
    return segmentsCompleted / segments.length;
  }
}
