import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/challenge.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/submodels/enrollment_class.dart';
import 'package:oluko_app/repositories/course_enrollment_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class CourseEnrollmentState {}

class Loading extends CourseEnrollmentState {}

class MarkSegmentSuccess extends CourseEnrollmentState {}

class UncompletedClassSuccess extends CourseEnrollmentState {
  EnrollmentClass enrollmentClass;
  UncompletedClassSuccess({this.enrollmentClass});
}

class GetEnrollmentSuccess extends CourseEnrollmentState {
  CourseEnrollment courseEnrollment;
  GetEnrollmentSuccess({this.courseEnrollment});
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
  CourseEnrollmentBloc() : super(Loading());

  void create(User user, Course course) async {
    try {
      CourseEnrollment courseEnrollment = await CourseEnrollmentRepository.create(user, course);
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

  Future<CourseEnrollment> get(User user, Course course) async {
    emit(Loading());
    try {
      CourseEnrollment courseEnrollment = await CourseEnrollmentRepository.get(course, user);
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

  void markSegmentAsCompleted(CourseEnrollment courseEnrollment, int segmentIndex, int classIndex) async {
    try {
      await CourseEnrollmentRepository.markSegmentAsCompleted(courseEnrollment, segmentIndex, classIndex);
      emit(MarkSegmentSuccess());
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(Failure(exception: exception));
      rethrow;
    }
  }

  /*void setCourseEnrollmentChallengesDefaultValue() {
    emit(GetCourseEnrollmentChallenge(challenges: []));
  }*/
}
