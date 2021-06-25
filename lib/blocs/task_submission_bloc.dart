import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/task_submission.dart';
import 'package:oluko_app/models/submodels/video.dart';
import 'package:oluko_app/repositories/task_submission_repository.dart';

abstract class TaskSubmissionState {}

class Loading extends TaskSubmissionState {}

class CreateSuccess extends TaskSubmissionState {
  String taskSubmissionId;
  CreateSuccess({this.taskSubmissionId});
}

class UpdateSuccess extends TaskSubmissionState {}

class Failure extends TaskSubmissionState {
  final Exception exception;

  Failure({this.exception});
}

class TaskSubmissionBloc extends Cubit<TaskSubmissionState> {
  TaskSubmissionBloc() : super(Loading());

  void createTaskResponse(CollectionReference reference) {
    try {
      TaskSubmission newTaskResponse = TaskSubmission(video: Video());
      newTaskResponse = TaskSubmissionRepository.createTaskSubmission(
          newTaskResponse, reference);
      emit(CreateSuccess(taskSubmissionId: newTaskResponse.id));
    } catch (e) {
      emit(Failure(exception: e));
    }
  }

  void updateTaskResponseVideo(DocumentReference reference, Video video) async {
    try {
      await TaskSubmissionRepository.updateTaskSubmissionVideo(
          video, reference);
      emit(UpdateSuccess());
    } catch (e) {
      emit(Failure(exception: e));
    }
  }
}
