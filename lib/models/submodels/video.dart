import 'package:equatable/equatable.dart';

class Video extends Equatable {
  String url;
  String thumbUrl;
  double aspectRatio;
  String name;
  int duration;
  //TODO: Joaquin add me some urls

  Video({this.url, this.thumbUrl, this.aspectRatio, this.name, this.duration});

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
        url: json['url']?.toString(),
        thumbUrl: json['thumb_url']?.toString(),
        aspectRatio: json['aspect_ratio'] as double,
        name: json['name']?.toString(),
        duration: json['duration'] as int);
  }

  Map<String, dynamic> toJson() => {
        'url': url,
        'thumb_url': thumbUrl,
        'aspect_ratio': aspectRatio,
        'name': name,
        'duration': duration,
      };

  @override
  // TODO: implement props
  List<Object> get props => [url, thumbUrl, aspectRatio, name, duration];
}
