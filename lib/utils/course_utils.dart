import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/course_category.dart';
import 'package:oluko_app/models/course_category_item.dart';

class CourseUtils {
  static List<Course> filterByCategories(
      List<Course> courses, CourseCategory courseCategory) {
    List<Course> tasksToShow = [];
    courses.forEach((Course course) {
      List<String> courseIds = courseCategory.courses
          .map((CourseCategoryItem courseCategoryItem) =>
              courseCategoryItem.courseId)
          .toList();

      if (courseIds.indexOf(course.id) != -1) {
        tasksToShow.add(course);
      }
    });
    return tasksToShow;
  }

  static List<Course> sortByCategoriesIndex(
      List<Course> courses, CourseCategory courseCategory) {
    courses.sort((Course taskA, Course taskB) {
      CourseCategoryItem assessmentTaskA = courseCategory.courses.firstWhere(
          (CourseCategoryItem element) => element.courseId == taskA.id);
      CourseCategoryItem assessmentTaskB = courseCategory.courses.firstWhere(
          (CourseCategoryItem element) => element.courseId == taskB.id);
      return assessmentTaskA.index.compareTo(assessmentTaskB.index);
    });
    return courses;
  }
}
