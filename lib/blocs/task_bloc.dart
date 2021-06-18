import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/task.dart';
import 'package:oluko_app/repositories/task_repository.dart';

abstract class TaskState {}

class Loading extends TaskState {}

class Success extends TaskState {
  final List<Task> values;
  Success({this.values});
}

class Failure extends TaskState {
  final Exception exception;

  Failure({this.exception});
}

class TaskBloc extends Cubit<TaskState> {
  TaskBloc() : super(Loading());

  void get() async {
    if (!(state is Success)) {
      emit(Loading());
    }
    try {
      List<Task> tasks = await TaskRepository().getAll();
      emit(Success(values: tasks));
    } catch (e) {
      emit(Failure(exception: e));
    }
  }
}
