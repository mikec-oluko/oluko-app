import 'package:oluko_app/models/class.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/movement.dart';
import 'package:oluko_app/models/submodels/object_submodel.dart';

class CourseService {
  static List<Class> getCourseClasses(Course course, List<Class> classes) {
    List<Class> courseClasses = [];
    List<String> ids = [];
    List<Class> sortedClasses = [];

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
