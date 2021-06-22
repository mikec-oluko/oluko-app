import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/task_submission.dart';
import 'package:oluko_app/models/video.dart';
import 'package:oluko_app/repositories/task_submission_repository.dart';

abstract class TaskSubmissionState {}

class Loading extends TaskSubmissionState {}

class TaskSubmissionSuccess extends TaskSubmissionState {
  TaskSubmission taskSubmission;
  TaskSubmissionSuccess({this.taskSubmission});
}

class Failure extends TaskSubmissionState {
  final Exception exception;

  Failure({this.exception});
}

class TaskSubmissionBloc extends Cubit<TaskSubmissionState> {
  TaskSubmissionBloc() : super(Loading());

  void createTaskResponse(CollectionReference reference, Video video) {
    if (!(state is TaskSubmissionSuccess)) {
      emit(Loading());
    }
    try {
      TaskSubmission newTaskResponse = TaskSubmission(video: video);
      newTaskResponse =
          TaskSubmissionRepository.createTaskSubmission(newTaskResponse, reference);
      emit(TaskSubmissionSuccess(taskSubmission: newTaskResponse));
    } catch (e) {
      emit(Failure(exception: e));
    }
  }
}
