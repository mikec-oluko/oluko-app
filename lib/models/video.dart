class Video {
  String id;
  String videoUrl;
  String thumbUrl;
  String coverUrl;
  double aspectRatio;
  int uploadedAt;
  String videoName;
  String createdBy;

  Video(
      {this.id,
      this.videoUrl,
      this.thumbUrl,
      this.coverUrl,
      this.aspectRatio,
      this.uploadedAt,
      this.videoName,
      this.createdBy});

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
        id: json['id'],
        videoUrl: json['videoUrl'],
        thumbUrl: json['thumbUrl'],
        coverUrl: json['coverUrl'],
        aspectRatio: json['aspectRatio'],
        uploadedAt: json['uploadedAt'],
        videoName: json['videoName'],
        createdBy: json['createdBy']);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'videoUrl': videoUrl,
        'thumbUrl': thumbUrl,
        'coverUrl': coverUrl,
        'aspectRatio': aspectRatio,
        'uploadedAt': uploadedAt,
        'videoName': videoName,
        'createdBy': createdBy,
      };
}
