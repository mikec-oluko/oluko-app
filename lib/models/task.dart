import 'package:cloud_firestore/cloud_firestore.dart';
import 'base.dart';

class Task extends Base {
  String name;
  String video;
  String videoHls;
  String stepsDescription;
  String stepsTitle;
  String description;
  String shortDescription;
  String thumbnailImage;

  Task(
      {this.name,
      this.video,
      this.videoHls,
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

  factory Task.fromJson(Map<String, dynamic> json) {
    Task task = Task(
      name: json['name']?.toString(),
      video: json['video']?.toString(),
      videoHls: json['video_hls']?.toString(),
      stepsDescription: json['steps_description']?.toString(),
      stepsTitle: json['steps_title']?.toString(),
      description: json['description']?.toString(),
      shortDescription: json['short_description']?.toString(),
      thumbnailImage: json['thumbnail_image']?.toString(),
    );
    task.setBase(json);
    return task;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> taskJson = {
      'name': name,
      'video': video,
      'video_hls': videoHls,
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
