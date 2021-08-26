class Video{
  String url;
  String thumbUrl;
  double aspectRatio;
  String name;
  int duration;

  Video({this.url, this.thumbUrl, this.aspectRatio, this.name, this.duration});

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
        url: json['url'],
        thumbUrl: json['thumb_url'],
        aspectRatio: json['aspect_ratio'],
        name: json['name'],
        duration: json['duration']);
  }

  Map<String, dynamic> toJson() => {
        'url': url,
        'thumb_url': thumbUrl,
        'aspect_ratio': aspectRatio,
        'name': name,
        'duration': duration,
      };
}
