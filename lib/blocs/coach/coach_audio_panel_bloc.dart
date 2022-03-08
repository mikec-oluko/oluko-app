import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  CoachAudioPanelConfirmDelete({this.panelMaxSize = 200});
}

class CoachAudioPanelFailure extends CoachAudioPanelState {
  final dynamic exception;
  CoachAudioPanelFailure({this.exception});
}

class CoachAudioPanelBloc extends Cubit<CoachAudioPanelState> {
  CoachAudioPanelBloc() : super(CoachAudioPanelLoading());

  void get() async {
    try {} catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  void emitDefaultState() {
    emit(CoachAudioPanelDefault());
  }

  void emitDeleteState() {
    emit(CoachAudioPanelDeleted());
  }

  void emitRecordedState({Widget audioWidget}) {
    emit(CoachAudioPanelRecorded(audioRecoded: audioWidget));
  }

  void emitConfirmDeleteState() {
    emit(CoachAudioPanelConfirmDelete());
  }
}
