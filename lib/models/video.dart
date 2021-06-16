class Video {
  String url;
  String thumbUrl;
  double aspectRatio;
  String name;

  Video(
      {
      this.url,
      this.thumbUrl,
      this.aspectRatio,
      this.name});

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
        url: json['url'],
        thumbUrl: json['thumb_url'],
        aspectRatio: json['aspect_ratio'],
        name: json['name']);
  }

  Map<String, dynamic> toJson() => {
        'url': url,
        'thumb_url': thumbUrl,
        'aspect_ratio': aspectRatio,
        'name': name,
      };
}
