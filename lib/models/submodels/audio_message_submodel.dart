class AudioMessageSubmodel {
  String url;
  int duration;
  AudioMessageSubmodel({this.url, this.duration});

  factory AudioMessageSubmodel.fromJson(Map<String, dynamic> json) {
    return AudioMessageSubmodel(
      url: json['url']?.toString(),
      duration: json['duration'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'url': url,
        'duration': duration,
      };
}
