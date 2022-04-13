import 'package:flutter_bloc/flutter_bloc.dart';

abstract class StopwatchState {}

class StopwatchLoading extends StopwatchState {}

class UpdateStopwatchSuccess extends StopwatchState {
  final Duration duration;
  UpdateStopwatchSuccess({this.duration});
}

class StopwatchBloc extends Cubit<StopwatchState> {
  StopwatchBloc() : super(StopwatchLoading());

  void updateStopwatch(Duration duration) {
    emit(UpdateStopwatchSuccess(duration: duration));
  }
}
