class Assessment {
  Assessment({
    this.name,
    this.video,
    this.coverImage,
    this.thumbnailImage,
    this.description,
    this.tasks,
  });

  String name;
  String video;
  String coverImage;
  String thumbnailImage;
  String description;
  List<dynamic> tasks;

  Assessment.fromJson(Map json)
      : name = json['name'],
        video = json['video'],
        coverImage = json['cover_image'],
        thumbnailImage = json['thumbnail_image'],
        description = json['description'],
        tasks = json['tasks'];

  Map<String, dynamic> toJson() => {
        'name': name,
        'video': video,
        'cover_image': coverImage,
        'thumbnail_image': thumbnailImage,
        'description': description,
        'tasks': tasks,
      };
}
