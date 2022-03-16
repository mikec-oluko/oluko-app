import 'package:oluko_app/blocs/project_configuration_bloc.dart';
import 'package:oluko_app/models/enums/timer_model.dart';
import 'package:oluko_app/utils/sound_player.dart';

enum ClockStateEnum { work, rest, segmentStart }

enum SoundTypeEnum { fixed, calculated }

const assetsFileAddress = 'sounds/';

class SoundUtils {
  static void playSound(int timeLeft, int totalTime, int workState) {
    final List segmentClockSounds =
        (ProjectConfigurationBloc.courseConfiguration as Map)['sounds_configuration']['segment_clock_sounds'] as List;
    if (segmentClockSounds.isNotEmpty) {
      final posibleSounds = segmentClockSounds.where((sound) {
        if (sound['clock_state'] == workState) {
          if (sound['type'] == SoundTypeEnum.calculated.index) {
            if (totalTime != null && totalTime > 0 && timeLeft != null) {
              return sound['value'] == (timeLeft / totalTime);
            } else {
              return false;
            }
          } else {
            return sound['value'] == timeLeft;
          }
        }
        return false;
      }).toList();
      if (posibleSounds.isNotEmpty) {
        if (posibleSounds.length > 1) {
          final soundToPlay = getHighestPrioritySound(posibleSounds);
          if (existSoundAsset(soundToPlay)) {
            playAsset(soundToPlay);
          }
        } else if (posibleSounds != null && existSoundAsset(posibleSounds[0])) {
          playAsset(posibleSounds[0]);
        }
      }
    }
  }

  static Future<dynamic> playAsset(soundToPlay) => SoundPlayer.playAsset(asset: assetsFileAddress + soundToPlay['soundAsset'].toString());

  static bool existSoundAsset(soundToPlay) => soundToPlay != null && soundToPlay['soundAsset'] != null;

  static getHighestPrioritySound(List<dynamic> posibleSounds) {
    return posibleSounds.reduce((soundA, soundB) {
      if (double.tryParse(soundA['priority'].toString()) > double.tryParse(soundB['priority'].toString())) {
        return soundA;
      } else {
        return soundB;
      }
    });
  }
}
