import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mvt_fitness/models/challenge.dart';
import 'package:mvt_fitness/models/course.dart';
import 'package:mvt_fitness/models/course_enrollment.dart';
import 'package:mvt_fitness/models/submodels/enrollment_class.dart';
import 'package:mvt_fitness/repositories/course_enrollment_repository.dart';

abstract class CourseEnrollmentState {}

class Loading extends CourseEnrollmentState {}

class UncompletedClassSuccess extends CourseEnrollmentState {
  EnrollmentClass enrollmentClass;
  UncompletedClassSuccess({this.enrollmentClass});
}

class GetEnrollmentSuccess extends CourseEnrollmentState {
  CourseEnrollment courseEnrollment;
  GetEnrollmentSuccess({this.courseEnrollment});
}

class Failure extends CourseEnrollmentState {
  final Exception exception;

  Failure({this.exception});
}

class GetCourseEnrollmentChallenge extends CourseEnrollmentState {
  final List<Challenge> challenges;

  GetCourseEnrollmentChallenge({this.challenges});
}

class CourseEnrollmentListSuccess extends CourseEnrollmentState {
  final List<CourseEnrollment> courseEnrollmentList;

  CourseEnrollmentListSuccess({this.courseEnrollmentList});
}

class CourseEnrollmentCourses extends CourseEnrollmentState {
  final List<Course> courseEnrollmentCourses;

  CourseEnrollmentCourses({this.courseEnrollmentCourses});
}

class CourseEnrollmentBloc extends Cubit<CourseEnrollmentState> {
  CourseEnrollmentBloc() : super(Loading());

  void create(User user, Course course) async {
    try {
      CourseEnrollment courseEnrollment =
          await CourseEnrollmentRepository.create(user, course);
      emit(GetEnrollmentSuccess(courseEnrollment: courseEnrollment));
    } catch (e) {
      emit(Failure(exception: e));
    }
  }

  void get(User user, Course course) async {
    try {
      CourseEnrollment courseEnrollment =
          await CourseEnrollmentRepository.get(course, user);
      emit(GetEnrollmentSuccess(courseEnrollment: courseEnrollment));
    } catch (e) {
      print(e.toString());
      emit(Failure(exception: e));
    }
  }

  void getChallengesForUser(String userId) async {
    try {
      List<Challenge> courseEnrollmentsChallenges =
          await CourseEnrollmentRepository().getUserChallengesuserId(userId);

      emit(GetCourseEnrollmentChallenge(
          challenges: courseEnrollmentsChallenges));
    } catch (e) {
      emit(Failure(exception: e));
    }
  }

  void getCourseEnrollmentsByUserId(String userId) async {
    try {
      List<CourseEnrollment> courseEnrollments =
          await CourseEnrollmentRepository.getUserCourseEnrollments(userId);
      emit(
          CourseEnrollmentListSuccess(courseEnrollmentList: courseEnrollments));
    } catch (e) {
      emit(Failure(exception: e));
    }
  }

  void getCourseEnrollmentsCoursesByUserId(String userId) async {
    try {
      List<Course> coursesFromEnrollments =
          await CourseEnrollmentRepository.getUserCourseEnrollmentsCourse(
              userId);
      emit(CourseEnrollmentCourses(
          courseEnrollmentCourses: coursesFromEnrollments));
    } catch (e) {
      emit(Failure(exception: e));
    }
  }
}
