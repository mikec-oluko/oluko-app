class Course {
  Course({this.name, this.imageUrl});

  String name;
  String imageUrl;

  Course.fromJson(Map json)
      : name = json['name'],
        imageUrl = json['image_url'];

  Map<String, dynamic> toJson() => {
        'name': name,
        'image_url': imageUrl,
      };
}
