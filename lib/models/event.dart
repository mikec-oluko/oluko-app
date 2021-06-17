enum EventType { play, pause}

class Event {
  String id;
  int position;
  EventType eventType;

  Event({
    this.id,
    this.position,
    this.eventType,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      position: json['position'],
      eventType: json['eventType'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'position': position,
        'eventType': eventType,
      };
}
