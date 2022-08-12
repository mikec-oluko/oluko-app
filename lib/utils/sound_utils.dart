import 'package:oluko_app/blocs/notification_settings_bloc.dart';
import 'package:oluko_app/blocs/project_configuration_bloc.dart';
import 'package:oluko_app/models/sound.dart';
import 'package:oluko_app/utils/sound_player.dart';
import 'package:sound_mode/sound_mode.dart';
import 'package:sound_mode/utils/ringer_mode_statuses.dart';

enum ClockStateEnum { work, rest, segmentStart }

enum SoundTypeEnum { fixed, calculated }

const assetsFileAddress = 'sounds/';

class SoundUtils {
  static void playSound(int timeLeft, int totalTime, int workState) {
    if (NotificationSettingsBloc.areSegmentClockNotificationEnabled()) {
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
              playAsset(soundToPlay);
            }
          } else if (posibleSounds != null && existSoundAsset(posibleSounds[0])) {
            playAsset(posibleSounds[0]);
          }
        }
      }
    }
  }

  static Future<dynamic> playAsset(Sound soundToPlay) => SoundPlayer.playAsset(asset: assetsFileAddress + soundToPlay.soundAsset);

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

  static Future<bool> canPlaySound() async {
    final RingerModeStatus _deviceSoundStatus = await SoundMode.ringerModeStatus;
    return _deviceSoundStatus == RingerModeStatus.normal || _deviceSoundStatus == RingerModeStatus.unknown;
  }
}
