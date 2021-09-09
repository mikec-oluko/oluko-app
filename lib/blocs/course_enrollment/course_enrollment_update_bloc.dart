import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/submodels/counter.dart';
import 'package:oluko_app/models/submodels/movement_submodel.dart';
import 'package:oluko_app/repositories/course_enrollment_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class CourseEnrollmentUpdateState {}

class Loading extends CourseEnrollmentUpdateState {}

class Failure extends CourseEnrollmentUpdateState {
  final Exception exception;
  Failure({this.exception});
}

class UpdateCounterSuccess extends CourseEnrollmentUpdateState {}

class SaveSelfieSuccess extends CourseEnrollmentUpdateState {
  CourseEnrollment courseEnrollment;
  SaveSelfieSuccess({this.courseEnrollment});
}

class CourseEnrollmentUpdateBloc extends Cubit<CourseEnrollmentUpdateState> {
  CourseEnrollmentUpdateBloc() : super(Loading());

  void saveMovementCounter(CourseEnrollment courseEnrollment, int segmentIndex,
      int classIndex, MovementSubmodel movement, Counter counter) async {
    try {
      await CourseEnrollmentRepository.saveMovementCounter(
          courseEnrollment, segmentIndex, classIndex, movement, counter);
      emit(UpdateCounterSuccess());
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(Failure(exception: exception));
    }
  }

  void saveSelfie(CourseEnrollment courseEnrollment, int classIndex,
      PickedFile file) async {
    emit(Loading());
    try {
      CourseEnrollment courseUpdated =
          await CourseEnrollmentRepository.updateSelfie(
              courseEnrollment, classIndex, file);
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
