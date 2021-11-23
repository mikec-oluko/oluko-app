import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class CoachIntroductionVideoState {}

class CoachIntroductionVideoLoading extends CoachIntroductionVideoState {}

class CoachIntroductionVideoPause extends CoachIntroductionVideoState {
  final bool pauseVideo;
  CoachIntroductionVideoPause({this.pauseVideo});
}

class CoachAudioFailure extends CoachIntroductionVideoState {
  final dynamic exception;
  CoachAudioFailure({this.exception});
}

class CoachIntroductionVideoBloc extends Cubit<CoachIntroductionVideoState> {
  CoachIntroductionVideoBloc() : super(CoachIntroductionVideoLoading());

  void pauseVideoForNavigation() async {
    emit(CoachIntroductionVideoLoading());
    try {
      emit(CoachIntroductionVideoPause(pauseVideo: true));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(CoachAudioFailure(exception: exception));
      rethrow;
    }
  }
}
