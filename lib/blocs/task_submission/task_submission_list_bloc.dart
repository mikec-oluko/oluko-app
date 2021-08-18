import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/assessment_assignment.dart';
import 'package:oluko_app/models/task_submission.dart';
import 'package:oluko_app/repositories/task_submission_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class TaskSubmissionListState {}

class Loading extends TaskSubmissionListState {}

class GetTaskSubmissionSuccess extends TaskSubmissionListState {
  List<TaskSubmission> taskSubmissions;
  GetTaskSubmissionSuccess({this.taskSubmissions});
}

class Failure extends TaskSubmissionListState {
  final Exception exception;

  Failure({this.exception});
}

class TaskSubmissionListBloc extends Cubit<TaskSubmissionListState> {
  TaskSubmissionListBloc() : super(Loading());

  void get(AssessmentAssignment assessmentAssignment) async {
    try {
      List<TaskSubmission> taskSubmissions =
          await TaskSubmissionRepository.getTaskSubmissions(
              assessmentAssignment);
      emit(GetTaskSubmissionSuccess(taskSubmissions: taskSubmissions));
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      emit(Failure(exception: e));
    }
  }
}
