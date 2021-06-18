class Task {
  Task(
      {this.name,
      this.video,
      this.stepsDescription,
      this.stepsTitle,
      this.description,
      this.shortDescription,
      this.thumbnailImage});

  String name;
  String video;
  String stepsDescription;
  String stepsTitle;
  String description;
  String shortDescription;
  String thumbnailImage;

  Task.fromJson(Map json)
      : name = json['name'],
        video = json['video'],
        stepsDescription = json['steps_description'],
        stepsTitle = json['steps_title'],
        description = json['description'],
        shortDescription = json['short_description'],
        thumbnailImage = json['thumbnail_image'];

  Map<String, dynamic> toJson() => {
        'name': name,
        'video': video,
        'steps_description': stepsDescription,
        'steps_title': stepsTitle,
        'description': description,
        'short_description': shortDescription,
        'thumbnail_image': thumbnailImage
      };
}
