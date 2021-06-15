class Task {
  Task({this.name, this.description, this.image, this.index});

  String name;
  String image;
  String description;
  num index;

  Task.fromJson(Map json)
      : name = json['name'],
        description = json['description'],
        image = json['image'],
        index = json['index'];

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'image': image,
        'index': index
      };
}
