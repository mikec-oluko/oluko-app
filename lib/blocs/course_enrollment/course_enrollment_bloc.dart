import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/submodels/enrollment_class.dart';
import 'package:oluko_app/repositories/course_enrollment_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:oluko_app/utils/schedule_utils.dart';

abstract class CourseEnrollmentState {}

class CourseEnrollmentLoading extends CourseEnrollmentState {}

class UncompletedClassSuccess extends CourseEnrollmentState {
  EnrollmentClass enrollmentClass;
  UncompletedClassSuccess({this.enrollmentClass});
}

class GetEnrollmentSuccess extends CourseEnrollmentState {
  CourseEnrollment courseEnrollment;
  GetEnrollmentSuccess({this.courseEnrollment});
}

class GetAllEnrollmentSuccess extends CourseEnrollmentState {
  List<CourseEnrollment> enrolledCourses;
  List<CourseEnrollment> previousEnrolled;
  GetAllEnrollmentSuccess({this.enrolledCourses, this.previousEnrolled});
}

class GetEnrollmentByIdSuccess extends CourseEnrollmentState {
  CourseEnrollment courseEnrollment;
  GetEnrollmentByIdSuccess({this.courseEnrollment});
}

class CreateEnrollmentSuccess extends CourseEnrollmentState {
  CourseEnrollment courseEnrollment;
  CreateEnrollmentSuccess({this.courseEnrollment});
}

class Failure extends CourseEnrollmentState {
  final dynamic exception;

  Failure({this.exception});
}

class CourseEnrollmentListSuccess extends CourseEnrollmentState {
  final List<CourseEnrollment> courseEnrollmentList;

  CourseEnrollmentListSuccess({this.courseEnrollmentList});
}

class CourseEnrollmentBloc extends Cubit<CourseEnrollmentState> {
  CourseEnrollmentBloc() : super(CourseEnrollmentLoading());

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>> subscription;
  @override
  void dispose() {
    if (subscription != null) {
      subscription.cancel();
      subscription = null;
    }
  }

  Future<void> create(User user, Course course) async {
    try {
      final CourseEnrollment courseEnrollment = await CourseEnrollmentRepository.create(user, course);
      emit(CreateEnrollmentSuccess(courseEnrollment: courseEnrollment));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(Failure(exception: exception));
      rethrow;
    }
  }

  Future<void> scheduleCourse(CourseEnrollment enrolledCourse, List<DateTime> scheduledDates, int lastCompletedClassIndex) async {
    try {
      final DateTime scheduleDatesFromNow = DateTime.now();
      ScheduleUtils.scheduleUncompletedClasses(enrolledCourse.classes, lastCompletedClassIndex, weekDays: enrolledCourse.weekDays, scheduleDatesFrom: scheduleDatesFromNow);
      await CourseEnrollmentRepository.scheduleCourse(enrolledCourse);
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(Failure(exception: exception));
      rethrow;
    }
  }

  Future<CourseEnrollment> get(String userId, Course course) async {
    emit(CourseEnrollmentLoading());
    try {
      CourseEnrollment courseEnrollment = await CourseEnrollmentRepository.get(course, userId);
      emit(GetEnrollmentSuccess(courseEnrollment: courseEnrollment));
      return courseEnrollment;
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(Failure(exception: exception));
      rethrow;
    }
  }

  void getById(String id) async {
    try {
      CourseEnrollment courseEnrollment = await CourseEnrollmentRepository.getById(id);
      emit(GetEnrollmentByIdSuccess(courseEnrollment: courseEnrollment));
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
    return subscription ??= CourseEnrollmentRepository.getUserCourseEnrollmentsSubscription(userId).listen((snapshot) async {
      List<CourseEnrollment> actualEnrolledCourses = [];
      List<CourseEnrollment> previousEnrolledCourses = [];
      try {
        snapshot.docs.forEach((doc) {
          CourseEnrollment enrollmentElement = CourseEnrollment.fromJson(doc.data());
          if (enrollmentElement.isUnenrolled || enrollmentElement.completion >= 1) {
            previousEnrolledCourses.add(enrollmentElement);
          } else {
            actualEnrolledCourses.add(enrollmentElement);
          }
        });
        emit(GetAllEnrollmentSuccess(enrolledCourses: actualEnrolledCourses, previousEnrolled: previousEnrolledCourses));
      } catch (exception, stackTrace) {
        await Sentry.captureException(
          exception,
          stackTrace: stackTrace,
        );
        emit(Failure(exception: exception));
      }
    }, onError: (dynamic error, StackTrace stackTrace) async {
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
      );
      emit(Failure(exception: error));
    });
  }
}
