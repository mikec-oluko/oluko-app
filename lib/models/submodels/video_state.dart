import 'package:enum_to_string/enum_to_string.dart';
import 'package:oluko_app/models/enums/submission_state_enum.dart';

class VideoState{
  String stateInfo;
  SubmissionStateEnum state;

  VideoState({
    this.state,
    this.stateInfo,

  });

  factory VideoState.fromJson(Map<String, dynamic> json) {
    return VideoState(
      stateInfo: json['state_info'],
      state: EnumToString.fromString(SubmissionStateEnum.values, json['state']),
    );
  }

  Map<String, dynamic> toJson() => {
        'state_info': stateInfo,
        'state': EnumToString.convertToString(state),
      };
}
