import 'package:headset_connection_event/headset_event.dart';
import 'package:oluko_app/blocs/notification_settings_bloc.dart';
import 'package:oluko_app/blocs/project_configuration_bloc.dart';
import 'package:oluko_app/models/sound.dart';
import 'package:oluko_app/utils/sound_player.dart';
import 'package:sound_mode/sound_mode.dart';
import 'package:sound_mode/utils/ringer_mode_statuses.dart';

enum ClockStateEnum { work, rest, segmentStart }

enum SoundTypeEnum { fixed, calculated }

const assetsFileAddress = 'sounds/';
final SoundPlayer _soundPlayer = SoundPlayer();

class SoundUtils {
  static Future<void> playSound(int timeLeft, int totalTime, int workState, {HeadsetState headsetState, bool isForWatch = false}) async {
    if (NotificationSettingsBloc.areSegmentClockNotificationEnabled() && await SoundUtils.canPlaySound(headsetState: headsetState, isForWatch: isForWatch)) {
      final List<Sound> segmentClockSounds = ProjectConfigurationBloc().getSegmentClockSounds();
      if (segmentClockSounds.isNotEmpty) {
        final List<Sound> posibleSounds = segmentClockSounds.where((sound) {
          if (sound.clockState.index == workState) {
            if (sound.type.index == SoundTypeEnum.calculated.index && (workState != ClockStateEnum.segmentStart.index)) {
              if (totalTime != null && totalTime > 0 && timeLeft != null) {
                return sound.value == (timeLeft / totalTime);
              } else {
                return false;
              }
            } else {
              return sound.value.toInt() == timeLeft;
            }
          }
          return false;
        }).toList();
        if (posibleSounds.isNotEmpty) {
          if (posibleSounds.length > 1) {
            final Sound soundToPlay = getHighestPrioritySound(posibleSounds);
            if (existSoundAsset(soundToPlay)) {
              _playAsset(soundToPlay, headsetState: headsetState, isForWatch: isForWatch);
            }
          } else if (posibleSounds != null && existSoundAsset(posibleSounds[0])) {
            _playAsset(posibleSounds[0], headsetState: headsetState, isForWatch: isForWatch);
          }
        }
      }
    }
  }

  static dynamic _playAsset(Sound soundToPlay, {HeadsetState headsetState, bool isForWatch = false}) =>
      _soundPlayer.playAsset(asset: assetsFileAddress + soundToPlay.soundAsset, headsetState: headsetState, isForWatch: isForWatch);

  static bool existSoundAsset(Sound soundToPlay) => soundToPlay != null && soundToPlay.soundAsset != null;

  static Sound getHighestPrioritySound(List<Sound> posibleSounds) {
    return posibleSounds.reduce((soundA, soundB) {
      if (soundA.priority > soundB.priority) {
        return soundA;
      } else {
        return soundB;
      }
    });
  }

  static Future<bool> canPlaySound({HeadsetState headsetState, bool isForWatch = false}) async {
    final RingerModeStatus deviceSoundStatus = await SoundMode.ringerModeStatus;
    if (isForWatch) {
      return true;
    } else {
      return (deviceSoundStatus == RingerModeStatus.normal || deviceSoundStatus == RingerModeStatus.unknown) ||
          (headsetState != null && headsetState == HeadsetState.CONNECT);
    }
  }
}
