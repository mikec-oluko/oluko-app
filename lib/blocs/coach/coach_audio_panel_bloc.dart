import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/coach_audio_message.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class GenericAudioPanelState {}

class GenericAudioPanelLoading extends GenericAudioPanelState {}

class GenericAudioPanelDefault extends GenericAudioPanelState {
  final double panelMaxSize;
  GenericAudioPanelDefault({this.panelMaxSize = 100});
}

class GenericAudioPanelRecorded extends GenericAudioPanelState {
  final double panelMaxSize;
  final Widget audioRecoded;
  GenericAudioPanelRecorded({this.panelMaxSize = 200, this.audioRecoded});
}

class GenericAudioPanelDeleted extends GenericAudioPanelState {
  final double panelMaxSize;
  GenericAudioPanelDeleted({this.panelMaxSize = 100});
}

class GenericAudioPanelConfirmDelete extends GenericAudioPanelState {
  final double panelMaxSize;
  final bool isAudioPreview;
  final CoachAudioMessage audioMessage;
  GenericAudioPanelConfirmDelete({this.panelMaxSize = 200, this.isAudioPreview = false, this.audioMessage});
}

class GenericAudioPanelFailure extends GenericAudioPanelState {
  final dynamic exception;
  GenericAudioPanelFailure({this.exception});
}

class GenericAudioPanelBloc extends Cubit<GenericAudioPanelState> {
  GenericAudioPanelBloc() : super(GenericAudioPanelLoading());

  void emitDefaultState() {
    emit(GenericAudioPanelDefault());
  }

  void emitDeleteState() {
    emit(GenericAudioPanelDeleted());
  }

  void emitRecordedState({Widget audioWidget}) {
    emit(GenericAudioPanelRecorded(audioRecoded: audioWidget));
  }

  void emitConfirmDeleteState({bool isPreviewContent, CoachAudioMessage audioMessageItem}) {
    emit(GenericAudioPanelConfirmDelete(isAudioPreview: isPreviewContent, audioMessage: audioMessageItem));
  }
}
