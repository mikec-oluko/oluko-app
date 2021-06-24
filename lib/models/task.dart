import 'package:cloud_firestore/cloud_firestore.dart';
import 'base.dart';

class Task extends Base {
  Task({
    this.key,
    this.name,
    this.video,
    this.stepsDescription,
    this.stepsTitle,
    this.description,
    this.shortDescription,
    this.thumbnailImage,
    Timestamp createdAt,
    String createdBy,
    Timestamp updatedAt,
    String updatedBy,
  }) : super(
            createdBy: createdBy,
            createdAt: createdAt,
            updatedAt: updatedAt,
            updatedBy: updatedBy);

  String key;
  String name;
  String video;
  String stepsDescription;
  String stepsTitle;
  String description;
  String shortDescription;
  String thumbnailImage;

  factory Task.fromJson(Map json) {
    return Task(
        key: json['key'],
        name: json['name'],
        video: json['video'],
        stepsDescription: json['steps_description'],
        stepsTitle: json['steps_title'],
        description: json['description'],
        shortDescription: json['short_description'],
        thumbnailImage: json['thumbnail_image'],
        createdAt: json['created_at'],
        createdBy: json['created_by']);
  }

  Map<String, dynamic> toJson() => {
        'key': key,
        'name': name,
        'video': video,
        'steps_description': stepsDescription,
        'steps_title': stepsTitle,
        'description': description,
        'short_description': shortDescription,
        'thumbnail_image': thumbnailImage,
        'created_at': createdAt == null ? createdAtSentinel : createdAt,
        'created_by': createdBy,
        'updated_at': updatedAt == null ? updatedAtSentinel : updatedAt,
        'updated_by': updatedBy,
      };
}
