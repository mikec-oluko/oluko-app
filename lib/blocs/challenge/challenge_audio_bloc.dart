import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/challenge.dart';
import 'package:oluko_app/models/submodels/audio.dart';
import 'package:oluko_app/repositories/challenge_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class ChallengeAudioState {}

class Loading extends ChallengeAudioState {}

class Failure extends ChallengeAudioState {
  final dynamic exception;
  Failure({this.exception});
}

class DeleteChallengeAudioSuccess extends ChallengeAudioState {}

class ChallengeAudioBloc extends Cubit<ChallengeAudioState> {
  ChallengeAudioBloc() : super(Loading());

  void markAudioAsDeleted(Challenge challenge, List<Audio> audios) async {
    try {
      await ChallengeRepository.markAudioAsDeleted(challenge, audios);
      emit(DeleteChallengeAudioSuccess());
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
