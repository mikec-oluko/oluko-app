import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/submodels/enrollment_segment.dart';

class ChallengeNavigation {
  CourseEnrollment enrolledCourse;
  EnrollmentSegment challengeSegment;
  int courseIndex, segmentIndex, classIndex;
  ChallengeNavigation({this.enrolledCourse, this.challengeSegment, this.segmentIndex, this.classIndex, this.courseIndex});
}
