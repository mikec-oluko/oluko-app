import 'package:oluko_app/models/class.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/movement.dart';
import 'package:oluko_app/models/submodels/object_submodel.dart';

class CourseService {
  static List<Class> getCourseClasses(Course course, List<Class> classes) {
    List<Class> courseClasses = [];
    List<String> ids = [];

    if (course.classes == null) {
      return courseClasses;
    }
    for (ObjectSubmodel classObj in course.classes) {
      ids.add(classObj.id);
    }
    classes.forEach((classObj) {
      if (ids.contains(classObj.id)) {
        courseClasses.add(classObj);
      }
    });
    return courseClasses;
  }
}
