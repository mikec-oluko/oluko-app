import 'package:enum_to_string/enum_to_string.dart';
import 'package:oluko_app/models/enums/submission_state_enum.dart';

class VideoState {
  String stateInfo;
  String stateExtraInfo;
  SubmissionStateEnum state;
  String error;

  VideoState({
    this.state,
    this.stateInfo,
    this.stateExtraInfo,
    this.error,
  });

  factory VideoState.fromJson(Map<String, dynamic> json) {
    return VideoState(
      stateInfo: json['state_info'].toString(),
      stateExtraInfo: json['state_extra_info'].toString(),
      error: json['error'].toString(),
      state: EnumToString.fromString(
          SubmissionStateEnum.values, json['state'].toString()),
    );
  }

  Map<String, dynamic> toJson() => {
        'state_info': stateInfo,
        'state_extra_info': stateExtraInfo,
        'error': error,
        'state': EnumToString.convertToString(state),
      };
}
