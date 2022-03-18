import 'package:flutter_bloc/flutter_bloc.dart';

abstract class CurrentTimeState {}

class CurrentTimeValue extends CurrentTimeState {
  final Duration timerTask;
  CurrentTimeValue({this.timerTask});
}

class CurrentTimeBloc extends Cubit<CurrentTimeState> {
  CurrentTimeBloc() : super(null);
  setCurrentTimeValue(Duration currentTime) {
    emit(CurrentTimeValue(timerTask: currentTime));
  }

  setCurrentTimeZero() {
    emit(CurrentTimeValue());
  }
}
