import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/course_category.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/repositories/course_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class CourseHomeState {}

class CourseHomeLoading extends CourseHomeState {}

class GetByCourseEnrollmentsSuccess extends CourseHomeState {
  final List<Course> courses;
  GetByCourseEnrollmentsSuccess({this.courses});
}

class CourseFailure extends CourseHomeState {
  final dynamic exception;

  CourseFailure({this.exception});
}

class CourseHomeBloc extends Cubit<CourseHomeState> {
  CourseHomeBloc() : super(CourseHomeLoading());

  void getByCourseEnrollments(List<CourseEnrollment> courseEnrollments) async {
    emit(CourseHomeLoading());
    try {
      List<Course> courses = await CourseRepository.getByCourseEnrollments(courseEnrollments);
      emit(GetByCourseEnrollmentsSuccess(courses: courses));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(CourseFailure(exception: exception));
      rethrow;
    }
  }
}
