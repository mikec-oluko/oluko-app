import 'package:flutter_bloc/flutter_bloc.dart';

abstract class TimerTaskState {}

class TimerTaskLoading extends TimerTaskState {}

class SetTimerTaskIndex extends TimerTaskState {
  final int timerTaskIndex;
  SetTimerTaskIndex({this.timerTaskIndex});
}

class SetShareDone extends TimerTaskState {
  final bool shareDone;
  SetShareDone({this.shareDone});
}

class TimerTaskBloc extends Cubit<TimerTaskState> {
  TimerTaskBloc() : super(TimerTaskLoading());

  void setTimerTaskIndex(int timerTaskIndex) {
    emit(SetTimerTaskIndex(timerTaskIndex: timerTaskIndex));
  }

  void setShareDone(bool shareDone) {
    emit(SetShareDone(shareDone: shareDone));
  }
}
