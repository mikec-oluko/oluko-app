import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mvt_fitness/models/submodels/video_info.dart';

import 'base.dart';

class TaskReview extends Base {
  VideoInfo videoInfo;
  DocumentReference taskSubmissionReference;

  TaskReview(
      {this.videoInfo,
      this.taskSubmissionReference,
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

  factory TaskReview.fromJson(Map<String, dynamic> json) {
    TaskReview taskReview = TaskReview(
      videoInfo: VideoInfo.fromJson(json['video_info']),
      taskSubmissionReference: json['task_submission_reference'],
    );
    taskReview.setBase(json);
    return taskReview;
  }

  setBase(Map<String, dynamic> json) {
    super.setBase(json);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> taskReviewJson = {
      'video_info': videoInfo.toJson(),
      'task_submission_reference': taskSubmissionReference,
    };
    taskReviewJson.addEntries(super.toJson().entries);
    return taskReviewJson;
  }
}
