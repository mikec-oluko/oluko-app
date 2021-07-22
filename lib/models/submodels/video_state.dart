import 'package:enum_to_string/enum_to_string.dart';
import 'package:oluko_app/models/enums/submission_state_enum.dart';

class VideoState{
  String stateInfo;
  SubmissionStateEnum state;
  String error;

  VideoState({
    this.state,
    this.stateInfo,
    this.error,
  });

  factory VideoState.fromJson(Map<String, dynamic> json) {
    return VideoState(
      stateInfo: json['state_info'],
      error: json['error'],
      state: EnumToString.fromString(SubmissionStateEnum.values, json['state']),
    );
  }

  Map<String, dynamic> toJson() => {
        'state_info': stateInfo,
        'error': error,
        'state': EnumToString.convertToString(state),
      };
}
