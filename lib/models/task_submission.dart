import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/base.dart';
import 'package:oluko_app/models/submodels/video.dart';

class TaskSubmission extends Base {
  Video video;
  DocumentReference reviewReference;
  DocumentReference taskReference;
  String taskId;

  TaskSubmission(
      {this.video,
      this.reviewReference,
      this.taskReference,
      this.taskId,
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

  factory TaskSubmission.fromJson(Map<String, dynamic> json) {
    TaskSubmission taskSubmission = TaskSubmission(
        video: json['video'] == null ? null : Video.fromJson(json['video']),
        reviewReference: json['review_reference'],
        taskReference: json['task_reference'],
        taskId: json['task_id']);
    taskSubmission.setBase(json);
    return taskSubmission;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> taskSubmissionJson = {
      'video': video == null ? null : video.toJson(),
      'review_reference': reviewReference,
      'task_reference': taskReference,
      'task_id': taskId
    };
    taskSubmissionJson.addEntries(super.toJson().entries);
    return taskSubmissionJson;
  }
}
