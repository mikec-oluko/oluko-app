import 'package:oluko_app/utils/sound_utils.dart';

class Sound {
  ClockStateEnum clockState;
  int priority;
  String soundAsset;
  SoundTypeEnum type;
  double value;

  Sound({this.clockState, this.priority, this.soundAsset, this.type, this.value});

  Sound.fromJson(Map json)
      : clockState = json['clock_state'] == null || json['clock_state'] is! int ? null : ClockStateEnum.values[json['clock_state'] as int],
        priority = json['priority'] == null || json['priority'] is! int ? 0 : json['priority'] as int,
        soundAsset = json['soundAsset'] == null ? '' : json['soundAsset'].toString(),
        type = json['type'] == null || json['type'] is! int ? null : SoundTypeEnum.values[json['type'] as int],
        value = json['value'] == null || (json['value'] is! double && json['value'] is! int ) ? 0 : double.tryParse(json['value'].toString());
}
