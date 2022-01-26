import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/challenge.dart';
import 'package:oluko_app/models/submodels/audio.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/repositories/challenge_repository.dart';
import 'package:oluko_app/utils/video_process.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:uuid/uuid.dart';

abstract class AudioState {}

class Loading extends AudioState {}

class AudioSuccess extends AudioState {
  Audio audio;
  AudioSuccess({this.audio});
}

class AudioFailure extends AudioState {
  final String exceptionMessage;
  AudioFailure({this.exceptionMessage});
}

class AudioBloc extends Cubit<AudioState> {
  AudioBloc() : super(Loading());

  Future<void> saveAudio(File audioFile, UserResponse user, String challengeId) async {
    try {
      Audio audio;
      audio = await _processAudio(audioFile, user);
      print("S3 bucket URL: " + audio.url);
      await ChallengeRepository.saveAudio(challengeId, audio);
      emit(AudioSuccess(audio: audio));
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      emit(AudioFailure(exceptionMessage: e.toString()));
      rethrow;
    }
  }

  Future<Audio> _processAudio(File audioFile, UserResponse user) async {
    String audioName = user.id;
    var uuid = Uuid();
    String audioId = uuid.v1();
    Audio audio = Audio(id: audioId, userId: user.id, userAvatarThumbnail: user.avatarThumbnail, userName: user.firstName);
    final Directory extDir = await getApplicationDocumentsDirectory();
    final outDirPath = '${extDir.path}/Audios/$audioId';
    final audiosDir = new Directory(outDirPath);
    audiosDir.createSync(recursive: true);
    final audioPath = audioFile.path;

    audio = await uploadAudio(audio, audioPath);

    return audio;
  }

  Future<Audio> uploadAudio(Audio audio, String audioPath) async {
    String audioUrl;
    if (audioPath != null) {
      audioUrl = await VideoProcess.uploadFile(audioPath, audio.id);
      audio.url = audioUrl;
    }
    return audio;
  }
}
