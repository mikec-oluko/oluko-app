import 'package:equatable/equatable.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/submodels/enrollment_segment.dart';

class ChallengeNavigation extends Equatable {
  CourseEnrollment enrolledCourse;
  EnrollmentSegment challengeSegment;
  int courseIndex, segmentIndex, classIndex;
  ChallengeNavigation({this.enrolledCourse, this.challengeSegment, this.segmentIndex, this.classIndex, this.courseIndex});

  @override
  List<Object> get props => [enrolledCourse, challengeSegment, segmentIndex, classIndex, courseIndex];
}
