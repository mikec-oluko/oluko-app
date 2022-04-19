import 'package:flutter_bloc/flutter_bloc.dart';

abstract class PanelAudioState {}

class PanelAudioDefault extends PanelAudioState {}

class PanelAudioSuccess extends PanelAudioState {
  bool audioRecorded;
  bool stopRecording;
  PanelAudioSuccess({this.audioRecorded, this.stopRecording});
}

class PanelAudioFailure extends PanelAudioState {
  dynamic exception;
  PanelAudioFailure({this.exception});
}

class PanelAudioBloc extends Cubit<PanelAudioState> {
  PanelAudioBloc() : super(PanelAudioDefault());

  void deleteAudio(bool audioRecorded, bool stopRecording) {
    emit(PanelAudioSuccess(audioRecorded: audioRecorded, stopRecording: stopRecording));
  }

  void emitDefaultState() {
    emit(PanelAudioDefault());
  }
}
