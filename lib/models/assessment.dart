import 'package:cloud_firestore/cloud_firestore.dart';

import 'base.dart';

class Assessment extends Base {
  Assessment(
      {this.name,
      this.video,
      this.coverImage,
      this.thumbnailImage,
      this.description,
      this.tasks,
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

  String name;
  String video;
  String coverImage;
  String thumbnailImage;
  String description;
  List<dynamic> tasks;

  factory Assessment.fromJson(Map<String, dynamic> json) {
    Assessment assessment = Assessment(
      name: json['name'],
      video: json['video'],
      coverImage: json['cover_image'],
      thumbnailImage: json['thumbnail_image'],
      description: json['description'],
      tasks: json['tasks'],
    );
    assessment.setBase(json);
    return assessment;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> assessmentJson = {
      'name': name,
      'video': video,
      'cover_image': coverImage,
      'thumbnail_image': thumbnailImage,
      'description': description,
      'tasks': tasks,
    };
    assessmentJson.addEntries(super.toJson().entries);
    return assessmentJson;
  }
}
