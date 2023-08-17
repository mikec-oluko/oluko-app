import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/course/course_home_bloc.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/models/workout_schedule.dart';
import 'package:oluko_app/routes.dart';

class ScheduleHelper {
  static Future<void> navigateToCourseSelectedScheduledClass(
      BuildContext context, WorkoutSchedule workoutSchedule, List<CourseEnrollment> courseEnrollmentList, List<Course> courses) async {
    final DocumentSnapshot courseSnapshot = await workoutSchedule.courseEnrollment.course.reference.get();
    final Course selectedCourse = Course.fromJson(courseSnapshot.data() as Map<String, dynamic>);
    final courseIndex = courses.indexWhere((course) => course.id == selectedCourse.id);
    final courseEnrollmentIndex = courseEnrollmentList.indexWhere((courseEnrollment) => courseEnrollment.id == workoutSchedule.courseEnrollment.id);

    Navigator.pushNamed(
      context,
      routeLabels[RouteEnum.insideClass],
      arguments: {
        'courseEnrollment': courseEnrollmentList[courseEnrollmentIndex],
        'classIndex': workoutSchedule.classIndex,
        'courseIndex': courseIndex,
        'actualCourse': selectedCourse
      },
    );
  }

  static Future<void> goToEditSchedule(BuildContext context, WorkoutSchedule workoutSchedule, AuthSuccess authState, UserResponse currentUserLatestVersion,
      {bool isPanelOpen = false, Function(bool) isPanelOpenAction}) async {
    BlocProvider.of<CourseHomeBloc>(context).getByCourseEnrollments([workoutSchedule.courseEnrollment]);
    final DocumentSnapshot courseSnapshot = await workoutSchedule.courseEnrollment.course.reference.get();
    final Course actualCourse = Course.fromJson(courseSnapshot.data() as Map<String, dynamic>);
    isPanelOpenAction(false);
    Navigator.pushNamed(
      context,
      routeLabels[RouteEnum.courseHomePage],
      arguments: {
        'courseEnrollments': [workoutSchedule.courseEnrollment],
        'authState': authState,
        'courses': [actualCourse],
        'user': currentUserLatestVersion,
        'isFromHome': true,
        'openEditScheduleOnInit': true,
      },
    );
  }
}
