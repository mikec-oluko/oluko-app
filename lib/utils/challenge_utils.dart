import 'package:flutter/widgets.dart';
import 'package:oluko_app/helpers/challenge_navigation.dart';
import 'package:oluko_app/models/class.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/submodels/enrollment_class.dart';
import 'package:oluko_app/models/submodels/enrollment_segment.dart';
import 'package:oluko_app/models/submodels/segment_submodel.dart';

class ChallengeUtils {
  static List<ChallengeNavigation> getChallenges(Class classElement, CourseEnrollment courseEnrollment, int classIndex, int courseIndex) {
    List<SegmentSubmodel> challenges = [];
    List<ChallengeNavigation> challengesForNavigation = [];
    classElement.segments.forEach((SegmentSubmodel segment) {
      if (segment.image != null && segment.isChallenge) {
        int segmentPos = classElement.segments.indexOf(segment);

        SegmentSubmodel previousSegment = segmentPos > 0 ? classElement.segments.elementAt(segmentPos - 1) : null;

        EnrollmentClass classWithSegments = courseEnrollment.classes.where((actualClass) => actualClass.id == classElement.id).toList().first;
        List<EnrollmentSegment> segmentFromClass = classWithSegments.segments.where((segmentElement) => segmentElement.id == segment.id).toList();
        if (segmentFromClass.isNotEmpty) {
          setChallengeImageIfNotFound(segmentFromClass.first, segment);

          EnrollmentSegment lastSegment =
              previousSegment != null ? classWithSegments.segments.where((segmentElement) => segmentElement.id == previousSegment.id).toList().first : null;

          challengesForNavigation.add(createChallengeForNavigation(
              courseEnrollment: courseEnrollment,
              segmentFromCourseEnrollment: segmentFromClass.first,
              classFromCourseEnrollment: classWithSegments,
              previousSegmentFinished: previousSegment != null ? lastSegment.completedAt != null : true,
              segmentIndex: classWithSegments.segments.indexOf(segmentFromClass.first),
              segmentId: segmentFromClass.first.id,
              classId: classWithSegments.id,
              classIndex: classIndex,
              courseIndex: courseIndex));
        }
      }
    });
    return challengesForNavigation;
  }

  static ChallengeNavigation createChallengeForNavigation({
    @required CourseEnrollment courseEnrollment,
    @required EnrollmentSegment segmentFromCourseEnrollment,
    @required EnrollmentClass classFromCourseEnrollment,
    @required bool previousSegmentFinished,
    @required int segmentIndex,
    @required int classIndex,
    @required int courseIndex,
    @required String segmentId,
    @required String classId,
  }) {
    ChallengeNavigation _newChallengeNavigation = ChallengeNavigation(
        enrolledCourse: courseEnrollment,
        challengeSegment: segmentFromCourseEnrollment,
        segmentIndex: segmentIndex,
        segmentId: segmentId,
        classIndex: classIndex,
        classId: classId,
        courseIndex: courseIndex,
        previousSegmentFinish: previousSegmentFinished);

    return _newChallengeNavigation;
  }

  static void setChallengeImageIfNotFound(EnrollmentSegment segmentFromClass, SegmentSubmodel segment) {
    segmentFromClass.image ??= segment.image;
  }
}
