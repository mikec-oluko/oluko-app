import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:oluko_app/models/assessment.dart';
import 'package:oluko_app/models/assessment_assignment.dart';
import 'package:oluko_app/models/task.dart';
import 'package:oluko_app/models/task_submission.dart';
import 'package:oluko_app/models/submodels/video.dart';
import 'package:oluko_app/repositories/assessment_assignment_repository.dart';
import 'package:oluko_app/repositories/task_submission_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class TaskSubmissionState {}

class Loading extends TaskSubmissionState {}

class CreateSuccess extends TaskSubmissionState {
  TaskSubmission taskSubmission;
  CreateSuccess({this.taskSubmission});
}

class GetSuccess extends TaskSubmissionState {
  TaskSubmission taskSubmission;
  GetSuccess({this.taskSubmission});
}

class GetUserTaskSubmissionSuccess extends TaskSubmissionState {
  List<TaskSubmission> taskSubmissions;
  GetUserTaskSubmissionSuccess({this.taskSubmissions});
}

class TaskSubmissionDefault extends TaskSubmissionState {
  List<TaskSubmission> taskSubmissions;
  TaskSubmissionDefault({this.taskSubmissions});
}

class PrivacyUpdatedSuccess extends TaskSubmissionState {
  bool isPublic;
  PrivacyUpdatedSuccess({this.isPublic});
}

class UpdateSuccess extends TaskSubmissionState {}

class Failure extends TaskSubmissionState {
  final dynamic exception;

  Failure({this.exception});
}

class TaskSubmissionBloc extends Cubit<TaskSubmissionState> {
  TaskSubmissionBloc() : super(Loading());

  Future<void> createTaskSubmission(AssessmentAssignment assessmentAssignment, Task task, bool isPublic, bool isLastTask) async {
    emit(Loading());
    try {
      TaskSubmission newTaskSubmission =
          await TaskSubmissionRepository.createTaskSubmission(assessmentAssignment, task, isPublic, isLastTask);
      emit(CreateSuccess(taskSubmission: newTaskSubmission));
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      emit(Failure(exception: e));
      rethrow;
    }
  }

  void updateTaskSubmissionPrivacity(AssessmentAssignment assessmentA, String taskSubmissionId, bool isPublic) async {
    try {
      await TaskSubmissionRepository.updateTaskSubmissionPrivacity(assessmentA, taskSubmissionId, isPublic);
      emit(PrivacyUpdatedSuccess(isPublic: isPublic));
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      print(e.toString());
      //emit(Failure(exception: e));
      rethrow;
    }
  }

  void getTaskSubmissionOfTask(AssessmentAssignment assessmentAssignment, String taskId) async {
    try {
      TaskSubmission taskSubmission = await TaskSubmissionRepository.getTaskSubmissionOfTask(assessmentAssignment, taskId);
      if (taskSubmission == null || taskSubmission.video == null || taskSubmission.video.url == null) {
        taskSubmission = null;
      }
      emit(GetSuccess(taskSubmission: taskSubmission));
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      emit(Failure(exception: e));
      rethrow;
    }
  }

  void setLoaderTaskSubmissionOfTask() {
    emit(Loading());
  }

  void getTaskSubmissionByUserId(String userId) async {
    emit(Loading());
    try {
      List<TaskSubmission> taskSubmissions = await TaskSubmissionRepository.getTaskSubmissionsByUserId(userId);
      emit(GetUserTaskSubmissionSuccess(taskSubmissions: taskSubmissions));
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      emit(Failure(exception: e));
      rethrow;
    }
  }

  Future<Timestamp> setCompleted(String assessmentAssignmentId) async {
    if (assessmentAssignmentId != null) {
      try {
        return AssessmentAssignmentRepository.setAsCompleted(assessmentAssignmentId);
      } catch (e, stackTrace) {
        await Sentry.captureException(
          e,
          stackTrace: stackTrace,
        );
        emit(Failure(exception: e));
        rethrow;
      }
    }
    return null;
  }

  void setIncompleted(String assessmentAssignmentId) async {
    if (assessmentAssignmentId != null) {
      try {
        AssessmentAssignmentRepository.setAsIncompleted(assessmentAssignmentId);
      } catch (e, stackTrace) {
        await Sentry.captureException(
          e,
          stackTrace: stackTrace,
        );
        emit(Failure(exception: e));
        rethrow;
      }
    }
  }

  void setTaskSubmissionDefaultState() {
    emit(TaskSubmissionDefault(taskSubmissions: []));
  }
}
