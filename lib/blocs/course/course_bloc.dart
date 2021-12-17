import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/course_category.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/repositories/course_category_repository.dart';
import 'package:oluko_app/repositories/course_repository.dart';
import 'package:oluko_app/utils/course_utils.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class CourseState {}

class CourseLoading extends CourseState {}

class CourseSuccess extends CourseState {
  final List<Course> values;
  final Map<CourseCategory, List<Course>> coursesByCategories;
  CourseSuccess({this.values, this.coursesByCategories});
}

class GetCourseSuccess extends CourseState {
  final Course course;
  GetCourseSuccess({this.course});
}

class UserEnrolledCoursesSuccess extends CourseState {
  final List<Course> courses;
  UserEnrolledCoursesSuccess({this.courses});
}

class CourseFailure extends CourseState {
  final dynamic exception;

  CourseFailure({this.exception});
}

class CourseBloc extends Cubit<CourseState> {
  CourseBloc() : super(CourseLoading());

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>> subscription;
  @override
  void dispose() {
    if (subscription != null) {
      subscription.cancel();
      subscription = null;
    }
  }

  void get() async {
    emit(CourseLoading());
    try {
      List<Course> courses = await CourseRepository().getAll();
      emit(CourseSuccess(values: courses));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(CourseFailure(exception: exception));
      rethrow;
    }
  }

  void getById(String id) async {
    emit(CourseLoading());
    try {
      Course course = await CourseRepository.get(id);
      emit(GetCourseSuccess(course: course));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(CourseFailure(exception: exception));
      rethrow;
    }
  }

  void getUserEnrolled(String userId) async {
    emit(CourseLoading());
    try {
      List<Course> enrolledCourses = await CourseRepository.getUserEnrolled(userId);
      emit(UserEnrolledCoursesSuccess(courses: enrolledCourses));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(CourseFailure(exception: exception));
      rethrow;
    }
  }

  void getByCategories() async {
    emit(CourseLoading());
    try {
      List<Course> courses = await CourseRepository().getAll();
      List<CourseCategory> courseCategories = await CourseCategoryRepository().getAll();
      Map<CourseCategory, List<Course>> mappedCourses = CourseUtils.mapCoursesByCategories(courses, courseCategories);
      emit(CourseSuccess(values: courses, coursesByCategories: mappedCourses));
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
