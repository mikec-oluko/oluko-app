import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/base.dart';
import 'package:oluko_app/models/submodels/video.dart';

class TaskSubmission extends Base {
  Video video;
  DocumentReference reviewReference;
  DocumentReference taskReference;

  TaskSubmission(
      {this.video,
      this.reviewReference,
      this.taskReference,
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
      video: Video.fromJson(json['video']),
      reviewReference: json['review_reference'],
      taskReference: json['task_reference'],
    );
    taskSubmission.setBase(json);
    return taskSubmission;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> taskSubmissionJson = {
      'video': video.toJson(),
      'review_reference': reviewReference,
      'task_reference': taskReference,
    };
    taskSubmissionJson.addEntries(super.toJson().entries);
    return taskSubmissionJson;
  }
}
