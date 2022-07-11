import 'package:cloud_firestore/cloud_firestore.dart';
import 'submodels/assessment_task.dart';
import 'base.dart';

class Assessment extends Base {
  Assessment(
      {this.name,
      this.video,
      this.videoThumbnail,
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
  String videoThumbnail;
  String coverImage;
  String thumbnailImage;
  String description;
  List<AssessmentTask> tasks;

  factory Assessment.fromJson(Map<String, dynamic> json) {
    Assessment assessment = Assessment(
      name: json['name']?.toString(),
      video: json['video']?.toString(),
      videoThumbnail: json['video_thumbnail']?.toString(),
      coverImage: json['cover_image']?.toString(),
      thumbnailImage: json['thumbnail_image']?.toString(),
      description: json['description']?.toString(),
      tasks: json['tasks'] != null
          ? (json['tasks'] as Iterable).map<AssessmentTask>((task) {
              AssessmentTask assessmentTask = AssessmentTask.fromJson(task as Map<dynamic, dynamic>);
              return assessmentTask;
            }).toList()
          : [],
    );
    assessment.setBase(json);
    return assessment;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> assessmentJson = {
      'name': name,
      'video': video,
      'video_thumbnail': videoThumbnail,
      'cover_image': coverImage,
      'thumbnail_image': thumbnailImage,
      'description': description,
      'tasks': tasks,
    };
    assessmentJson.addEntries(super.toJson().entries);
    return assessmentJson;
  }
}
