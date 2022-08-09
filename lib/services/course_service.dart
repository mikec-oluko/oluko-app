import 'package:oluko_app/models/class.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/enrollment_audio.dart';
import 'package:oluko_app/models/movement.dart';
import 'package:oluko_app/models/submodels/enrollment_class.dart';
import 'package:oluko_app/models/submodels/object_submodel.dart';

class CourseService {
  static List<Class> getCourseClasses(List<Class> classes, {CourseEnrollment courseEnrollment,Course course,}) {
    List<Class> courseClasses = [];
    List<String> ids = [];
    List<Class> sortedClasses = [];

    if (course == null && courseEnrollment==null) {
      return courseClasses;
    }
    if (courseEnrollment != null) {
      for (EnrollmentClass classObj in courseEnrollment.classes) {
        ids.add(classObj.id);
      }
    } else {
      for (ObjectSubmodel classObj in course.classes) {
        ids.add(classObj.id);
      }
    }

    classes.forEach((classObj) {
      if (ids.contains(classObj.id)) {
        courseClasses.add(classObj);
      }
    });

    ids.forEach((id) {
      List<Class> classes = courseClasses.where((element) => element.id == id).toList();
      if (classes.isNotEmpty) {
        Class classToAdd = classes[0];
        sortedClasses.add(classToAdd);
      }
    });

    return sortedClasses;
  }
}
