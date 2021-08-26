import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/base.dart';
import 'package:oluko_app/models/submodels/object_submodel.dart';
import 'package:oluko_app/models/submodels/video.dart';
import 'package:oluko_app/models/submodels/video_state.dart';

class TaskSubmission extends Base {
  Video video;
  DocumentReference reviewReference;
  ObjectSubmodel task;
  bool isPublic;
  VideoState videoState;

  TaskSubmission(
      {this.video,
      this.reviewReference,
      this.task,
      this.isPublic,
      this.videoState,
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
        task:
            json['task'] == null ? null : ObjectSubmodel.fromJson(json['task']),
        isPublic: json['is_public'],
        videoState: json['video_state'] == null
            ? null
            : VideoState.fromJson(json['video_state']));
    taskSubmission.setBase(json);
    return taskSubmission;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> taskSubmissionJson = {
      'video': video == null ? null : video.toJson(),
      'review_reference': reviewReference,
      'task': task == null ? null : task.toJson(),
      'is_public': isPublic,
      'video_state': videoState == null ? null : videoState.toJson()
    };
    taskSubmissionJson.addEntries(super.toJson().entries);
    return taskSubmissionJson;
  }
}
