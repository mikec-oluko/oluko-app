import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound_lite/flutter_sound.dart';
import 'package:headset_connection_event/headset_event.dart';
import 'package:just_audio/just_audio.dart';
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
  AudioSession session;
  bool get isPlaying => player.playing;
  AudioPlayer player;
  Future init() async {
    player = AudioPlayer(handleInterruptions: false, handleAudioSessionActivation: false, androidApplyAudioAttributes: false);
    session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playback,
      avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.mixWithOthers,
      avAudioSessionMode: AVAudioSessionMode.defaultMode,
      avAudioSessionRouteSharingPolicy: AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: AndroidAudioAttributes(
        contentType: AndroidAudioContentType.sonification,
        usage: AndroidAudioUsage.media,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gainTransientMayDuck,
      androidWillPauseWhenDucked: false,
    ));
    await session.setActive(true);
  }

  Future dispose() async {
    try {
      await player?.stop();
      await player?.dispose();
      await session.setActive(false);
    } catch (e) {
      print(e);
    }
  }

  Future _play(String uri, VoidCallback whenFinished) async {
    if (_audioPlayer.isPaused) {
      await _audioPlayer.resumePlayer();
    } else {
      await _audioPlayer.startPlayer(fromURI: uri, whenFinished: whenFinished);
    }
  }

  Future playAsset({SoundsEnum soundEnum, String asset, HeadsetState headsetState, bool isForWatch = false}) async {
    try {
      if (globalNotificationsEnabled(soundEnum) && await SoundUtils.canPlaySound(headsetState: headsetState, isForWatch: isForWatch)) {
        await init();
        String assetToPlay = asset;
        if (soundEnum != null) {
          final Map courseConfig = ProjectConfigurationBloc().getSoundsConfiguration();
          assetToPlay = courseConfig != null ? courseConfig[soundsLabels[soundEnum]].toString() : null;
        }
        if (assetToPlay != null && assetToPlay != 'null') {
          await player.setAsset('assets/${assetToPlay}');
          await player.play();
          if (Platform.isAndroid) {
            await player?.stop();
            await session.setActive(false);
          }
        }
      }
    } catch (e) {
      print(e);
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
