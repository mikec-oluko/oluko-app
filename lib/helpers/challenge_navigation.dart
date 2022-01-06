import 'package:equatable/equatable.dart';
import 'package:oluko_app/models/challenge.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/submodels/enrollment_segment.dart';

class ChallengeNavigation extends Equatable {
  CourseEnrollment enrolledCourse;
  EnrollmentSegment challengeSegment;
  String segmentId, classId;
  int courseIndex, segmentIndex, classIndex;
  bool previousSegmentFinish;
  Challenge challengeForAudio;
  ChallengeNavigation(
      {this.enrolledCourse,
      this.challengeSegment,
      this.segmentIndex,
      this.segmentId,
      this.classIndex,
      this.classId,
      this.courseIndex,
      this.challengeForAudio,
      this.previousSegmentFinish = false});

  @override
  List<Object> get props =>
      [enrolledCourse, challengeSegment, segmentIndex, classIndex, courseIndex, previousSegmentFinish, segmentId, classId];
}
