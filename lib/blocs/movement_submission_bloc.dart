import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mvt_fitness/models/course_enrollment.dart';
import 'package:mvt_fitness/models/movement_submission.dart';
import 'package:mvt_fitness/models/segment_submission.dart';
import 'package:mvt_fitness/repositories/movement_submission_repository.dart';
import 'package:mvt_fitness/repositories/segment_submission_repository.dart';

abstract class MovementSubmissionState {}

class Loading extends MovementSubmissionState {}

class CreateMovementSubmissionSuccess extends MovementSubmissionState {
  MovementSubmission movementSubmission;
  CreateMovementSubmissionSuccess({this.movementSubmission});
}

class UpdateMovementSubmissionSuccess extends MovementSubmissionState {
  MovementSubmission movementSubmission;
  UpdateMovementSubmissionSuccess({this.movementSubmission});
}

class Failure extends MovementSubmissionState {
  final Exception exception;

  Failure({this.exception});
}

class MovementSubmissionBloc extends Cubit<MovementSubmissionState> {
  MovementSubmissionBloc() : super(Loading());

  void create(SegmentSubmission segmentSubmission) async {
    try {
      MovementSubmission movementSubmission =
          await MovementSubmissionRepository.create(segmentSubmission);
      emit(CreateMovementSubmissionSuccess(
          movementSubmission: movementSubmission));
    } catch (e) {
      print(e.toString());
      emit(Failure(exception: e));
    }
  }

  void update(MovementSubmission movementSubmission) async {
    try {
      MovementSubmission updatedMovement =
          await MovementSubmissionRepository.update(movementSubmission);
      emit(
          CreateMovementSubmissionSuccess(movementSubmission: updatedMovement));
    } catch (e) {
      emit(Failure(exception: e));
    }
  }
}
