import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class CoachIntroductionVideoState {}

class CoachIntroductionVideoLoading extends CoachIntroductionVideoState {}

class CoachIntroductionVideoPause extends CoachIntroductionVideoState {
  final bool pauseVideo;
  CoachIntroductionVideoPause({this.pauseVideo});
}

class CoachIntroductionVideoFailure extends CoachIntroductionVideoState {
  final dynamic exception;
  CoachIntroductionVideoFailure({this.exception});
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
      emit(CoachIntroductionVideoFailure(exception: exception));
      rethrow;
    }
  }
}
