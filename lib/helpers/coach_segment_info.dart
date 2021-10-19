import 'package:oluko_app/models/submodels/enrollment_segment.dart';

class InfoForSegments {
  String courseEnrollmentId;
  String className;
  String classImage;
  List<EnrollmentSegment> segments;
  InfoForSegments({this.classImage, this.className, this.courseEnrollmentId, this.segments});
}
