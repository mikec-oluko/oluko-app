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

  /*
  Returns Map with a list of Courses for each Category
  */
  static Map<CourseCategory, List<Course>> mapCoursesByCategories(
      List<Course> courses, List<CourseCategory> courseCategories) {
    Map<CourseCategory, List<Course>> mappedCourses = {};
    courseCategories.forEach((courseCategory) {
      final List<Course> courseList =
          filterByCategories(courses, courseCategory);
      mappedCourses[courseCategory] = courseList;
    });
    return mappedCourses;
  }

  static List<Course> sortByCategoriesIndex(
      List<Course> courses, CourseCategory courseCategory) {
    courses.sort((Course taskA, Course taskB) {
      CourseCategoryItem courseCategoryA = courseCategory.courses.firstWhere(
          (CourseCategoryItem element) => element.courseId == taskA.id);
      CourseCategoryItem courseCategoryB = courseCategory.courses.firstWhere(
          (CourseCategoryItem element) => element.courseId == taskB.id);
      return courseCategoryA.index.compareTo(courseCategoryB.index);
    });
    return courses;
  }
}
