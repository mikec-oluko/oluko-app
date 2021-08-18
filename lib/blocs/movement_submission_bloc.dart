import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/enums/submission_state_enum.dart';
import 'package:oluko_app/models/movement_submission.dart';
import 'package:oluko_app/models/segment_submission.dart';
import 'package:oluko_app/models/submodels/movement_submodel.dart';
import 'package:oluko_app/repositories/movement_submission_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class MovementSubmissionState {}

class Loading extends MovementSubmissionState {}

class CreateMovementSubmissionSuccess extends MovementSubmissionState {
  MovementSubmission movementSubmission;
  CreateMovementSubmissionSuccess({this.movementSubmission});
}

class GetMovementSubmissionSuccess extends MovementSubmissionState {
  List<MovementSubmission> movementSubmissions;
  GetMovementSubmissionSuccess({this.movementSubmissions});
}

class UpdateMovementSubmissionSuccess extends MovementSubmissionState {}

class EncodedMovementSubmissionSuccess extends MovementSubmissionState {}

class ErrorMovementSubmissionSuccess extends MovementSubmissionState {}

class Failure extends MovementSubmissionState {
  final Exception exception;

  Failure({this.exception});
}

class MovementSubmissionBloc extends Cubit<MovementSubmissionState> {
  MovementSubmissionBloc() : super(Loading());

  void create(SegmentSubmission segmentSubmission, MovementSubmodel movement,
      String videoPath) async {
    try {
      MovementSubmission movementSubmission =
          await MovementSubmissionRepository.create(
              segmentSubmission, movement, videoPath);
      emit(CreateMovementSubmissionSuccess(
          movementSubmission: movementSubmission));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(Failure(exception: exception));
    }
  }

  void updateVideo(MovementSubmission movementSubmission) async {
    try {
      await MovementSubmissionRepository.updateVideo(movementSubmission);
      emit(UpdateMovementSubmissionSuccess());
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(Failure(exception: exception));
    }
  }

  void updateStateToEncoded(MovementSubmission movementSubmission) async {
    try {
      await MovementSubmissionRepository.updateStateToEncoded(
          movementSubmission);
      emit(EncodedMovementSubmissionSuccess());
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(Failure(exception: exception));
    }
  }

  void updateStateToError(MovementSubmission movementSubmission) async {
    try {
      await MovementSubmissionRepository.updateStateToError(movementSubmission);
      emit(ErrorMovementSubmissionSuccess());
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(Failure(exception: exception));
    }
  }

  void get(SegmentSubmission segmentSubmission) async {
    try {
      List<MovementSubmission> movementSubmissions =
          await MovementSubmissionRepository.get(segmentSubmission);
      emit(GetMovementSubmissionSuccess(
          movementSubmissions: movementSubmissions));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(Failure(exception: exception));
    }
  }
}
