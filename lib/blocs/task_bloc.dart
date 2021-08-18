import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/assessment.dart';
import 'package:oluko_app/models/task.dart';
import 'package:oluko_app/repositories/task_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class TaskState {}

class TaskLoading extends TaskState {}

class TaskSuccess extends TaskState {
  final List<Task> values;
  TaskSuccess({this.values});
}

class TaskFailure extends TaskState {
  final Exception exception;

  TaskFailure({this.exception});
}

class TaskBloc extends Cubit<TaskState> {
  TaskBloc() : super(TaskLoading());

  void get(Assessment assessment) async {
    if (!(state is TaskSuccess)) {
      emit(TaskLoading());
    }
    try {
      List<Task> tasks = await TaskRepository.getAllByAssessment(assessment);
      emit(TaskSuccess(values: tasks));
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      print(e.toString());
      emit(TaskFailure(exception: e));
    }
  }
}
