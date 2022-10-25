import 'package:audio_session/audio_session.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound_lite/flutter_sound.dart';
import 'package:headset_connection_event/headset_event.dart';
import 'package:oluko_app/blocs/notification_settings_bloc.dart';
import 'package:oluko_app/blocs/project_configuration_bloc.dart';
import 'package:oluko_app/utils/sound_utils.dart';

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
    await _audioPlayer.openAudioSession(
        category: SessionCategory.playAndRecord, focus: AudioFocus.requestFocusAndDuckOthers, mode: SessionMode.modeSpokenAudio);
  }

  static Future<AudioSession> setSessionConfig() async {
    AudioSession session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
    return session ??= await setSessionConfig();
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

  static Future playAsset({SoundsEnum soundEnum, String asset, HeadsetState headsetState, bool isForWatch = false}) async {
    AudioSession newSession = await setSessionConfig();
    if (globalNotificationsEnabled(soundEnum) && await SoundUtils.canPlaySound(headsetState: headsetState, isForWatch: isForWatch)) {
      final AudioCache player = AudioCache(duckAudio: true);
      String assetToPlay = asset;
      if (soundEnum != null) {
        final Map courseConfig = ProjectConfigurationBloc().getSoundsConfiguration();
        assetToPlay = courseConfig != null ? courseConfig[soundsLabels[soundEnum]].toString() : null;
      }
      if (assetToPlay != null && assetToPlay != 'null') {
        if (await newSession.setActive(true)) {
          await player.play(assetToPlay, mode: PlayerMode.LOW_LATENCY);
        }
      }
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

  static bool globalNotificationsEnabled(SoundsEnum soundEnum) {
    if (NotificationSettingsBloc.notificationSettings != null && soundEnum != null) {
      return NotificationSettingsBloc.notificationSettings.globalNotifications;
    }
    return true;
  }
}
