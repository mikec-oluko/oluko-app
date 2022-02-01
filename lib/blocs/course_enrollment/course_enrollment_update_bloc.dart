import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/submodels/movement_submodel.dart';
import 'package:oluko_app/repositories/course_enrollment_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class CourseEnrollmentUpdateState {}

class Loading extends CourseEnrollmentUpdateState {}

class Failure extends CourseEnrollmentUpdateState {
  final dynamic exception;
  Failure({this.exception});
}

class SaveSelfieSuccess extends CourseEnrollmentUpdateState {
  CourseEnrollment courseEnrollment;
  SaveSelfieSuccess({this.courseEnrollment});
}

class CourseEnrollmentUpdateBloc extends Cubit<CourseEnrollmentUpdateState> {
  CourseEnrollmentUpdateBloc() : super(Loading());

  void saveMovementCounter(CourseEnrollment courseEnrollment, int segmentIndex, int sectionIndex, int classIndex, MovementSubmodel movement,
      int totalRounds, int currentRound, int counter) async {
    try {
      await CourseEnrollmentRepository.saveMovementCounter(
          courseEnrollment, segmentIndex, classIndex, sectionIndex, movement, totalRounds, currentRound, counter);
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(Failure(exception: exception));
      rethrow;
    }
  }

  void saveSectionStopwatch(CourseEnrollment courseEnrollment, int segmentIndex, int sectionIndex, int classIndex, int totalRounds,
      int currentRound, int stopwatch) async {
    try {
      await CourseEnrollmentRepository.saveSectionStopwatch(
          courseEnrollment, segmentIndex, classIndex, sectionIndex, totalRounds, currentRound, stopwatch);
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(Failure(exception: exception));
      rethrow;
    }
  }

  void saveSelfie(CourseEnrollment courseEnrollment, int classIndex, XFile file) async {
    emit(Loading());
    try {
      CourseEnrollment courseUpdated = await CourseEnrollmentRepository.updateSelfie(courseEnrollment, classIndex, file);
      emit(SaveSelfieSuccess(courseEnrollment: courseUpdated));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(Failure(exception: exception));
    }
  }
}
