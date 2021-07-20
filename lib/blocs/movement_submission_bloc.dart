import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/movement_submission.dart';
import 'package:oluko_app/models/segment_submission.dart';
import 'package:oluko_app/models/submodels/movement_submodel.dart';
import 'package:oluko_app/repositories/movement_submission_repository.dart';

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

  void create(SegmentSubmission segmentSubmission, MovementSubmodel movement,
      String videoPath) async {
    try {
      MovementSubmission movementSubmission =
          await MovementSubmissionRepository.create(
              segmentSubmission, movement, videoPath);
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
