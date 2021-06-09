class Video {
  String id;
  String url;
  String thumbUrl;
  String coverUrl;
  double aspectRatio;
  int uploadedAt;
  String name;
  String createdBy;

  Video(
      {this.id,
      this.url,
      this.thumbUrl,
      this.coverUrl,
      this.aspectRatio,
      this.uploadedAt,
      this.name,
      this.createdBy});

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
        id: json['id'],
        url: json['url'],
        thumbUrl: json['thumb_url'],
        coverUrl: json['cover_url'],
        aspectRatio: json['aspect_ratio'],
        uploadedAt: json['uploaded_at'],
        name: json['name'],
        createdBy: json['created_by']);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'url': url,
        'thumb_url': thumbUrl,
        'cover_url': coverUrl,
        'aspect_ratio': aspectRatio,
        'uploaded_at': uploadedAt,
        'name': name,
        'created_by': createdBy,
      };
}
