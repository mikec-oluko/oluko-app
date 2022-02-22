import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/submodels/enrollment_segment.dart';

class InfoForSegments {
  CourseEnrollment courseEnrollment;
  String className;
  String classImage;
  int classIndex, courseIndex;
  List<EnrollmentSegment> enrollmentSegments;
  InfoForSegments({this.courseEnrollment, this.classImage, this.classIndex, this.courseIndex, this.className, this.enrollmentSegments});
}
