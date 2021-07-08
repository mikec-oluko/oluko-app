import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/models/task.dart';
import 'package:oluko_app/models/task_submission.dart';
import 'package:oluko_app/models/submodels/video.dart';
import 'package:oluko_app/repositories/task_submission_repository.dart';

abstract class TaskSubmissionState {}

class Loading extends TaskSubmissionState {}

class CreateSuccess extends TaskSubmissionState {
  String taskSubmissionId;
  CreateSuccess({this.taskSubmissionId});
}

class GetSuccess extends TaskSubmissionState {
  TaskSubmission taskSubmission;
  GetSuccess({this.taskSubmission});
}

class UpdateSuccess extends TaskSubmissionState {}

class Failure extends TaskSubmissionState {
  final Exception exception;

  Failure({this.exception});
}

class TaskSubmissionBloc extends Cubit<TaskSubmissionState> {
  TaskSubmissionBloc() : super(Loading());

  void createTaskSubmission(CollectionReference reference, Task task) {
    final DocumentReference taskReference = FirebaseFirestore.instance
        .collection("projects")
        .doc(GlobalConfiguration().getValue("projectId"))
        .collection("tasks")
        .doc(task.id);
    try {
      TaskSubmission newTaskSubmission = TaskSubmission(
          video: Video(), taskId: task.id, taskReference: taskReference);
      newTaskSubmission = TaskSubmissionRepository.createTaskSubmission(
          newTaskSubmission, reference);
      emit(CreateSuccess(taskSubmissionId: newTaskSubmission.id));
    } catch (e) {
      emit(Failure(exception: e));
    }
  }

  void updateTaskSubmissionVideo(DocumentReference reference, Video video) async {
    try {
      await TaskSubmissionRepository.updateTaskSubmissionVideo(
          video, reference);
      emit(UpdateSuccess());
    } catch (e) {
      emit(Failure(exception: e));
    }
  }

  void getTaskSubmissionOfTask(Task task) async {
    try {
      TaskSubmission taskSubmission =
          await TaskSubmissionRepository.getTaskSubmissionOfTask(task);
      if (taskSubmission != null && taskSubmission.video.url != null) {
        emit(GetSuccess(taskSubmission: taskSubmission));
      }
    } catch (e) {
      emit(Failure(exception: e));
    }
  }
}
