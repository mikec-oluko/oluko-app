import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ClocksTimerState {}

class ClocksTimerLoading extends ClocksTimerState {}

class UpdateTimeLeft extends ClocksTimerState {}

/*class SetTimerTaskIndex extends ClocksTimerState {
  final int timerTaskIndex;
  SetTimerTaskIndex({this.timerTaskIndex});
}*/

class ClocksTimerPlay extends ClocksTimerState {
  final Function() goToNextStep;
  final Function() setPaused;
  ClocksTimerPlay({this.goToNextStep, this.setPaused});
}

class ClocksTimerPause extends ClocksTimerState {
  final Function() setPaused;
  ClocksTimerPause({this.setPaused});
}

class ClocksTimerBloc extends Cubit<ClocksTimerState> {
  ClocksTimerBloc() : super(ClocksTimerLoading());

  void playCountdown(Function() goToNextStep, Function() setPaused) {
    emit(ClocksTimerPlay(goToNextStep: goToNextStep, setPaused: setPaused));
  }

  void pauseCountdown(Function() setPaused) {
    emit(ClocksTimerPause(setPaused: setPaused));
  }

  void updateTimeLeft() {
    emit(UpdateTimeLeft());
  }

  /*void setTimerTaskIndex(int timerTaskIndex) {
    emit(SetTimerTaskIndex(timerTaskIndex: timerTaskIndex));
  }*/
}
