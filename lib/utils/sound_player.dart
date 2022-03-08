import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound_lite/public/flutter_sound_player.dart';

enum SoundsEnum {
  enroll,
}

Map<SoundsEnum, String> soundsLabels = {SoundsEnum.enroll: 'sounds/enroll_sound.wav'};

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

  static Future playAsset(SoundsEnum soundEnum) async {
    final AudioCache player = AudioCache();
    final asset = soundsLabels[soundEnum];
    await player.play(asset);
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
