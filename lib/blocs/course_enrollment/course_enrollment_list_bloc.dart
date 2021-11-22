import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/repositories/course_enrollment_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class CourseEnrollmentListState {}

class Loading extends CourseEnrollmentListState {}

class Failure extends CourseEnrollmentListState {
  final dynamic exception;
  Failure({this.exception});
}

class CourseEnrollmentsByUserSuccess extends CourseEnrollmentListState {
  final List<CourseEnrollment> courseEnrollments;
  CourseEnrollmentsByUserSuccess({this.courseEnrollments});
}

class CourseEnrollmentListBloc extends Cubit<CourseEnrollmentListState> {
  CourseEnrollmentListBloc() : super(Loading());

  void getCourseEnrollmentsByUser(String userId) async {
    try {
      List<CourseEnrollment> courseEnrollments = await CourseEnrollmentRepository.getUserCourseEnrollments(userId);
      emit(CourseEnrollmentsByUserSuccess(courseEnrollments: courseEnrollments.where((element) => element.isUnenrolled != true).toList()));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(Failure(exception: exception));
      rethrow;
    }
  }

  void getCourseEnrollmentsByUserId(String userId) async {
    try {
      List<CourseEnrollment> courseEnrollments = await CourseEnrollmentRepository.getUserCourseEnrollments(userId);
      emit(CourseEnrollmentsByUserSuccess(courseEnrollments: courseEnrollments));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(Failure(exception: exception));
      rethrow;
    }
  }

  void unenrollCourseForUser(CourseEnrollment courseToUnenroll, bool isUnenrolledValue) async {
    try {
      CourseEnrollment courseEnrollmentUpdated =
          await CourseEnrollmentRepository.markCourseEnrollmentAsUnenrolled(courseToUnenroll, isUnenrolledValue);
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(Failure(exception: exception));
      rethrow;
    }
  }
}
