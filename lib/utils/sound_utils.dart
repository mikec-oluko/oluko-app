import 'package:oluko_app/blocs/project_configuration_bloc.dart';
import 'package:oluko_app/models/sound.dart';
import 'package:oluko_app/utils/sound_player.dart';

enum ClockStateEnum { work, rest, segmentStart }

enum SoundTypeEnum { fixed, calculated }

const assetsFileAddress = 'sounds/';

class SoundUtils {
  static void playSound(int timeLeft, int totalTime, int workState) {
    final List<Sound> segmentClockSounds = ProjectConfigurationBloc().getSegmentClockSounds();
    if (segmentClockSounds.isNotEmpty) {
      final List<Sound> posibleSounds = segmentClockSounds.where((sound) {
        if (sound.clockState.index == workState) {
          if (sound.type.index == SoundTypeEnum.calculated.index) {
            if (totalTime != null && totalTime > 0 && timeLeft != null) {
              return sound.value == (timeLeft / totalTime);
            } else {
              return false;
            }
          } else {
            return sound.value == timeLeft;
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

  static getHighestPrioritySound(List<Sound> posibleSounds) {
    return posibleSounds.reduce((soundA, soundB) {
      if (soundA.priority > soundB.priority) {
        return soundA;
      } else {
        return soundB;
      }
    });
  }
}
