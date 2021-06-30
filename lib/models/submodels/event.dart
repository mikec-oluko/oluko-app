import 'package:enum_to_string/enum_to_string.dart';

enum EventType { play, pause}

class Event {
  int position;
  EventType eventType;

  Event({
    this.position,
    this.eventType,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      position: json['position'],
      eventType: EnumToString.fromString(EventType.values, json['event_type']),
    );
  }

  Map<String, dynamic> toJson() => {
        'position': position,
        'event_type': EnumToString.convertToString(eventType),
      };
}
