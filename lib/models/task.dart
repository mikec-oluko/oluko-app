class Task {
  Task({this.name, this.video, this.description, this.image});

  String name;
  String video;
  String image;
  String description;

  Task.fromJson(Map json)
      : name = json['name'],
        video = json['video'],
        description = json['description'],
        image = json['image'];

  Map<String, dynamic> toJson() => {
        'name': name,
        'video': video,
        'description': description,
        'image': image,
      };
}
