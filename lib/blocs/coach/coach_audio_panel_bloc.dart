import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class CoachAudioPanelState {}

class CoachAudioPanelLoading extends CoachAudioPanelState {}

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
}
