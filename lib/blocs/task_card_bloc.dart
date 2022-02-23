import 'package:flutter_bloc/flutter_bloc.dart';

abstract class TaskCardState {}

class TaskCardLoading extends TaskCardState {}

class TaskCardVideoProcessing extends TaskCardState {
  final int taskIndex;
  TaskCardVideoProcessing({this.taskIndex});
}

class TaskCardFailure extends TaskCardState {
  final dynamic exception;

  TaskCardFailure({this.exception});
}

class TaskCardBloc extends Cubit<TaskCardState> {
  TaskCardBloc() : super(TaskCardLoading());

  void taskLoading(int taskIndex) {
    emit(TaskCardVideoProcessing(taskIndex: taskIndex));
  }
}
