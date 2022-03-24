import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound_lite/public/flutter_sound_player.dart';
import 'package:oluko_app/blocs/project_configuration_bloc.dart';

enum SoundsEnum { enroll, classFinished, newCoachRecomendation }

Map<SoundsEnum, String> soundsLabels = {
  SoundsEnum.enroll: 'enroll_to_course',
  SoundsEnum.classFinished: 'class_finished',
  SoundsEnum.newCoachRecomendation: 'new_coach_recomendation'
};

class SoundPlayer {
  FlutterSoundPlayer _audioPlayer;
  bool get isPlaying => _audioPlayer.isPlaying;

  Future init() async {
    _audioPlayer = FlutterSoundPlayer();
    await _audioPlayer.openAudioSession();
  }

  Future dispose() async {
    await _audioPlayer.closeAudioSession();
    _audioPlayer = null;
  }

  Future _play(String uri, VoidCallback whenFinished) async {
    if (_audioPlayer.isPaused) {
      await _audioPlayer.resumePlayer();
    } else {
      await _audioPlayer.startPlayer(fromURI: uri, whenFinished: whenFinished);
    }
  }

  static Future playAsset({SoundsEnum soundEnum, String asset}) async {
    final AudioCache player = AudioCache();
    String assetToPlay = asset;
    if (soundEnum != null) {
      final Map courseConfig = (ProjectConfigurationBloc.courseConfiguration as Map)['sounds_configuration'] as Map;
      assetToPlay = courseConfig[soundsLabels[soundEnum]].toString();
    }
    if(assetToPlay != null && assetToPlay != 'null') {
      await player.play(assetToPlay);
    }
  }

  Future _pause() async {
    await _audioPlayer.pausePlayer();
  }

  Future togglePlaying(String uri, VoidCallback whenFinished) async {
    if (!_audioPlayer.isPaused) {
      await _play(uri, whenFinished);
    } else {
      await _pause();
    }
  }
}
