import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/enums/submission_state_enum.dart';
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

class GetMovementSubmissionSuccess extends MovementSubmissionState {
  List<MovementSubmission> movementSubmissions;
  GetMovementSubmissionSuccess({this.movementSubmissions});
}

class UpdateMovementSubmissionSuccess extends MovementSubmissionState {}

class EncodedMovementSubmissionSuccess extends MovementSubmissionState {}

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

  void updateVideo(MovementSubmission movementSubmission) async {
    try {
      await MovementSubmissionRepository.updateVideo(movementSubmission);
      emit(UpdateMovementSubmissionSuccess());
    } catch (e) {
      print(e.toString());
      emit(Failure(exception: e));
    }
  }

    void updateStateToEncoded(MovementSubmission movementSubmission, String dir) async {
    try {
      await MovementSubmissionRepository.updateStateToEncoded(movementSubmission, dir);
      emit(EncodedMovementSubmissionSuccess());
    } catch (e) {
      print(e.toString());
      emit(Failure(exception: e));
    }
  }

  void get(SegmentSubmission segmentSubmission) async {
    try {
      List<MovementSubmission> movementSubmissions =
          await MovementSubmissionRepository.get(segmentSubmission);
      emit(GetMovementSubmissionSuccess(
          movementSubmissions: movementSubmissions));
    } catch (e) {
      emit(Failure(exception: e));
    }
  }
}
