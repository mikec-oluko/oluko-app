import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/assessment.dart';
import 'package:oluko_app/models/assessment_assignment.dart';
import 'package:oluko_app/models/submodels/video.dart';
import 'package:oluko_app/models/task_submission.dart';
import 'package:oluko_app/repositories/assessment_assignment_repository.dart';
import 'package:oluko_app/repositories/task_submission_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class TaskSubmissionListState {}

class Loading extends TaskSubmissionListState {}

class GetTaskSubmissionSuccess extends TaskSubmissionListState {
  List<TaskSubmission> taskSubmissions;
  GetTaskSubmissionSuccess({this.taskSubmissions});
}

class Failure extends TaskSubmissionListState {
  final dynamic exception;

  Failure({this.exception});
}

class TaskSubmissionListBloc extends Cubit<TaskSubmissionListState> {
  TaskSubmissionListBloc() : super(Loading());

  void get(AssessmentAssignment assessmentAssignment) async {
    try {
      List<TaskSubmission> taskSubmissions = await TaskSubmissionRepository.getTaskSubmissions(assessmentAssignment);
      emit(GetTaskSubmissionSuccess(taskSubmissions: taskSubmissions));
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      emit(Failure(exception: e));
      rethrow;
    }
  }

    void updateTaskSubmissionVideo(AssessmentAssignment assessmentA, String taskSubmissionId, Video video) async {
    emit(Loading());
    try {
      await TaskSubmissionRepository.updateTaskSubmissionVideo(assessmentA, taskSubmissionId, video);
      //emit(UpdateSuccess());
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      print(e.toString());
      emit(Failure(exception: e));
      rethrow;
    }
  }

    Future<bool> checkCompleted(AssessmentAssignment assessmentAssignment, Assessment assessment) async {
    try {
      List<TaskSubmission> taskSubmissions = await TaskSubmissionRepository.getTaskSubmissions(assessmentAssignment);
      if (taskSubmissions.length == assessment.tasks.length) {
        AssessmentAssignmentRepository.setAsCompleted(assessmentAssignment.id);
      }
      return false;
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
