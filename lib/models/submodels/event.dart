import 'package:enum_to_string/enum_to_string.dart';

enum EventType { play, pause }

class Event{
  int recordingPosition;
  int videoPosition;
  EventType eventType;

  Event({
    this.recordingPosition,
    this.videoPosition,
    this.eventType,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      recordingPosition: json['recording_position'],
      videoPosition: json['video_position'],
      eventType: EnumToString.fromString(EventType.values, json['event_type']),
    );
  }

  Map<String, dynamic> toJson() => {
        'recording_position': recordingPosition,
        'video_position': videoPosition,
        'event_type': EnumToString.convertToString(eventType),
      };
}
