class Alert {
  int time;
  String text;

  Alert({this.time, this.text});

  factory Alert.fromJson(Map<String, dynamic> json) {
    return Alert(
      time: json['time'] == null ? null : json['time'] as int,
      text: json['text']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'time': time,
        'text': text,
      };
}
