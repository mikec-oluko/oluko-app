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

class DeleteChallengeAudioSuccess extends ChallengeAudioState {
  final List<Audio> audios;
  DeleteChallengeAudioSuccess({this.audios});
}

class ChallengeAudioBloc extends Cubit<ChallengeAudioState> {
  ChallengeAudioBloc() : super(Loading());

  void markAudioAsDeleted(Challenge challenge, List<Audio> audiosUpdated, List<Audio> audios) async {
    try {
      await ChallengeRepository.markAudioAsDeleted(challenge, audiosUpdated);
      emit(DeleteChallengeAudioSuccess(audios: audios));
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
