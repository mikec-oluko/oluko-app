import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/base.dart';
import 'package:oluko_app/models/video.dart';

class TaskSubmission extends Base {
  String id;
  Video video;
  DocumentReference reviewReference;
  DocumentReference taskReference;

  TaskSubmission({
    this.id,
    this.video,
    this.reviewReference,
    this.taskReference,
  });

  factory TaskSubmission.fromJson(Map<String, dynamic> json) {
    return TaskSubmission(
      id: json['id'],
      video: Video.fromJson(json['video']),
      reviewReference: json['review_reference'],
      taskReference: json['task_reference'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'video': video.toJson(),
        'review_reference': reviewReference,
        'task_reference': taskReference,
      };
}
