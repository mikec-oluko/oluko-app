import 'package:flutter_bloc/flutter_bloc.dart';

abstract class PanelAudioState {}

class PanelAudioDefault extends PanelAudioState {}

class PanelAudioSuccess extends PanelAudioState {}

class PanelAudioFailure extends PanelAudioState {
  dynamic exception;
  PanelAudioFailure({this.exception});
}

class PanelAudioBloc extends Cubit<PanelAudioState> {
  PanelAudioBloc() : super(PanelAudioDefault());

  void deleteAudio() {
    emit(PanelAudioSuccess());
  }
}
