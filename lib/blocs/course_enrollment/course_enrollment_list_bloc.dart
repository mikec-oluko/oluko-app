import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
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

class GetCourseEnrollmentUpdate extends CourseEnrollmentListState {
  final List<CourseEnrollment> courseEnrollments;
  GetCourseEnrollmentUpdate({this.courseEnrollments});
}

class CourseEnrollmentListBloc extends Cubit<CourseEnrollmentListState> {
  CourseEnrollmentListBloc() : super(Loading());

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>> subscription;
  @override
  void dispose() {
    if (subscription != null) {
      subscription.cancel();
      subscription = null;
    }
  }

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

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>> getStream(String userId) {
    subscription ??= CourseEnrollmentRepository.getUserCourseEnrollmentsSubscription(userId).listen((snapshot) async {
      List<CourseEnrollment> courseEnrollments = [];
      snapshot.docs.forEach((doc) {
        final Map<String, dynamic> content = doc.data();
        courseEnrollments.add(CourseEnrollment.fromJson(content));
      });
      emit(CourseEnrollmentsByUserSuccess(courseEnrollments: courseEnrollments.where((element) => element.isUnenrolled != true).toList()));
    });
    return subscription;
  }
}
