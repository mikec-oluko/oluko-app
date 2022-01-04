import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/repositories/introduction_media_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class IntroductionMediaState {}

class Loading extends IntroductionMediaState {}

class Failure extends IntroductionMediaState {
  final dynamic exception;
  Failure({this.exception});
}

class Success extends IntroductionMediaState {
  final String mediaURL;
  Success({this.mediaURL});
}

class IntroductionMediaBloc extends Cubit<IntroductionMediaState> {
  IntroductionMediaBloc() : super(Loading());

  void getIntroVideo() async {
    try {
      final String mediaURL = await IntroductionMediaRepository.getIntroVideoURL();
      emit(Success(mediaURL: mediaURL));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(Failure(exception: exception));
      rethrow;
    }
  }
}
