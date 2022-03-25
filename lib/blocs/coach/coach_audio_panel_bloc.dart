import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/coach_audio_message.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class CoachAudioPanelState {}

class CoachAudioPanelLoading extends CoachAudioPanelState {}

class CoachAudioPanelDefault extends CoachAudioPanelState {
  final double panelMaxSize;
  CoachAudioPanelDefault({this.panelMaxSize = 100});
}

class CoachAudioPanelRecorded extends CoachAudioPanelState {
  final double panelMaxSize;
  final Widget audioRecoded;
  CoachAudioPanelRecorded({this.panelMaxSize = 200, this.audioRecoded});
}

class CoachAudioPanelDeleted extends CoachAudioPanelState {
  final double panelMaxSize;
  CoachAudioPanelDeleted({this.panelMaxSize = 100});
}

class CoachAudioPanelConfirmDelete extends CoachAudioPanelState {
  final double panelMaxSize;
  final bool isAudioPreview;
  final CoachAudioMessage audioMessage;
  CoachAudioPanelConfirmDelete({this.panelMaxSize = 200, this.isAudioPreview = false, this.audioMessage});
}

class CoachAudioPanelFailure extends CoachAudioPanelState {
  final dynamic exception;
  CoachAudioPanelFailure({this.exception});
}

class CoachAudioPanelBloc extends Cubit<CoachAudioPanelState> {
  CoachAudioPanelBloc() : super(CoachAudioPanelLoading());

  void emitDefaultState() {
    emit(CoachAudioPanelDefault());
  }

  void emitDeleteState() {
    emit(CoachAudioPanelDeleted());
  }

  void emitRecordedState({Widget audioWidget}) {
    emit(CoachAudioPanelRecorded(audioRecoded: audioWidget));
  }

  void emitConfirmDeleteState({bool isPreviewContent, CoachAudioMessage audioMessageItem}) {
    emit(CoachAudioPanelConfirmDelete(isAudioPreview: isPreviewContent, audioMessage: audioMessageItem));
  }
}
