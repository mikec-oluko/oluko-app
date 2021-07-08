import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/submodels/enrollment_class.dart';
import 'package:oluko_app/repositories/course_enrollment_repository.dart';

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
      emit(Failure(exception: e));
    }
  }
}
