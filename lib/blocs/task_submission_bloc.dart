import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/models/assessment_assignment.dart';
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

class GetUserTaskSubmissionSuccess extends TaskSubmissionState {
  List<TaskSubmission> taskSubmissions;
  GetUserTaskSubmissionSuccess({this.taskSubmissions});
}

class UpdateSuccess extends TaskSubmissionState {}

class Failure extends TaskSubmissionState {
  final Exception exception;

  Failure({this.exception});
}

class TaskSubmissionBloc extends Cubit<TaskSubmissionState> {
  TaskSubmissionBloc() : super(Loading());

  void createTaskSubmission(
      AssessmentAssignment assessmentAssignment, Task task) {
    try {
      TaskSubmission newTaskSubmission =
          TaskSubmissionRepository.createTaskSubmission(
              assessmentAssignment, task);
      emit(CreateSuccess(taskSubmissionId: newTaskSubmission.id));
    } catch (e) {
      emit(Failure(exception: e));
    }
  }

  void updateTaskSubmissionVideo(AssessmentAssignment assessmentA,
      String taskSubmissionId, Video video) async {
    try {
      await TaskSubmissionRepository.updateTaskSubmissionVideo(
          assessmentA, taskSubmissionId, video);
      emit(UpdateSuccess());
    } catch (e) {
      print(e.toString());
      emit(Failure(exception: e));
    }
  }

  void getTaskSubmissionOfTask(
      AssessmentAssignment assessmentAssignment, Task task) async {
    try {
      TaskSubmission taskSubmission =
          await TaskSubmissionRepository.getTaskSubmissionOfTask(
              assessmentAssignment, task);
      if (taskSubmission != null && taskSubmission.video.url == null) {
        taskSubmission = null;
      }
      emit(GetSuccess(taskSubmission: taskSubmission));
    } catch (e) {
      emit(Failure(exception: e));
    }
  }

  void getTaskSubmissionByUserId(String userId) async {
    try {
      List<TaskSubmission> taskSubmissions =
          await TaskSubmissionRepository.getTaskSubmissionsByUserId(userId);

      emit(GetUserTaskSubmissionSuccess(taskSubmissions: taskSubmissions));
    } catch (e) {
      emit(Failure(exception: e));
    }
  }
}
