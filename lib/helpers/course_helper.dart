import 'package:flutter/cupertino.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/submodels/enrollment_class.dart';
import 'package:oluko_app/models/submodels/object_submodel.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class CourseHelper {
  static double getAdaptiveSizeForTitle(int textLength, BuildContext context) {
    var width = ScreenUtils.width(context);
    int charactersPerLine = ((width * 25) / 375).toInt();
    if (textLength < charactersPerLine) {
      return ScreenUtils.height(context) * 0.09 * MediaQuery.of(context).textScaleFactor;
    } else {
      return ScreenUtils.height(context) * (0.09 + ((textLength ~/ charactersPerLine) - 0.5) * 0.09) * MediaQuery.of(context).textScaleFactor;
    }
    //0.08 is the minimun size for one line of title
    //25 are the characters that fit in 355 px
  }

  static void navigateToCourseFirstClassToComplete(
      {BuildContext context, List<Course> courses, List<CourseEnrollment> listOfCourseEnrollments, int currentCourseIndex}) {
    final Course courseSelected = courses.where((course) => course.id == listOfCourseEnrollments[currentCourseIndex].course.id).first;
    final EnrollmentClass _enrollmentClassToGo = getClassToGo(listOfCourseEnrollments[currentCourseIndex].classes, getFirstComplete: true);
    final ObjectSubmodel _classToGo = courses[courses.indexOf(courseSelected)].classes.where((element) => element.id == _enrollmentClassToGo.id).first;
    final courseIndex = courses.indexOf(courseSelected);
    final classIndex = courses[courseIndex].classes.indexOf(_classToGo);

    Navigator.pushNamed(
      context,
      routeLabels[RouteEnum.insideClass],
      arguments: {
        'courseEnrollment': listOfCourseEnrollments[currentCourseIndex],
        'classIndex': classIndex,
        'courseIndex': courses.indexOf(courseSelected),
        'actualCourse': courseSelected
      },
    );
  }

  static EnrollmentClass getClassToGo(List<EnrollmentClass> classes, {bool getFirstComplete = false}) {
    EnrollmentClass classToReturn = classes.lastWhere((element) => element.completedAt != null, orElse: () => null);
    if (classToReturn == null || !getFirstComplete) {
      classToReturn = classes.firstWhere((element) => element.completedAt == null);
    } else {
      if (classes.length != classes.indexOf(classToReturn)) {
        classToReturn = classes.elementAt(classes.indexOf(classToReturn) + 1);
      }
    }
    return classToReturn;
  }
}
