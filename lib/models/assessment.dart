import 'package:oluko_app/models/assessment_task.dart';

class Assessment {
  Assessment({
    this.id,
    this.name,
    this.video,
    this.coverImage,
    this.thumbnailImage,
    this.description,
    this.tasks,
  });

  String id;
  String name;
  String video;
  String coverImage;
  String thumbnailImage;
  String description;
  List<AssessmentTask> tasks;

  Assessment.fromJson(Map json)
      : id = json['id'],
        name = json['name'],
        video = json['video'],
        coverImage = json['cover_image'],
        thumbnailImage = json['thumbnail_image'],
        description = json['description'],
        tasks = json['tasks'] != null && json['tasks'].length > 0
            ? json['tasks'].map<AssessmentTask>((task) {
                AssessmentTask assessmentTask = AssessmentTask.fromJson(task);
                return assessmentTask;
              }).toList()
            : [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'video': video,
        'cover_image': coverImage,
        'thumbnail_image': thumbnailImage,
        'description': description,
        'tasks': tasks,
      };
}
