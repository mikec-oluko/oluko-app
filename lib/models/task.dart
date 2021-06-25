import 'package:cloud_firestore/cloud_firestore.dart';

import 'base.dart';

class Task extends Base {
  Task(
      {this.name,
      this.video,
      this.stepsDescription,
      this.stepsTitle,
      this.description,
      this.shortDescription,
      this.thumbnailImage,
      String id,
      Timestamp createdAt,
      String createdBy,
      Timestamp updatedAt,
      String updatedBy,
      bool isHidden,
      bool isDeleted})
      : super(
            id: id,
            createdBy: createdBy,
            createdAt: createdAt,
            updatedAt: updatedAt,
            updatedBy: updatedBy,
            isDeleted: isDeleted,
            isHidden: isHidden);

  String id;
  String name;
  String video;
  String stepsDescription;
  String stepsTitle;
  String description;
  String shortDescription;
  String thumbnailImage;

  factory Task.fromJson(Map<String, dynamic> json) {
    Task task = Task(
      name: json['name'],
      video: json['video'],
      stepsDescription: json['steps_description'],
      stepsTitle: json['steps_title'],
      description: json['description'],
      shortDescription: json['short_description'],
      thumbnailImage: json['thumbnail_image'],
    );
    task.setBase(json);
    return task;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> taskJson = {
      'name': name,
      'video': video,
      'steps_description': stepsDescription,
      'steps_title': stepsTitle,
      'description': description,
      'short_description': shortDescription,
      'thumbnail_image': thumbnailImage
    };
    taskJson.addEntries(super.toJson().entries);
    return taskJson;
  }
}
