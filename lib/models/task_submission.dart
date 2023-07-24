import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:oluko_app/models/base.dart';
import 'package:oluko_app/models/submodels/object_submodel.dart';
import 'package:oluko_app/models/submodels/video.dart';
import 'package:oluko_app/models/submodels/video_state.dart';

class TaskSubmission extends Base with EquatableMixin {
  Video video;
  String videoHls;
  DocumentReference reviewReference;
  ObjectSubmodel task;
  bool isPublic;
  VideoState videoState;
  String coachId;
  DocumentReference coachReference;

  TaskSubmission(
      {this.video,
      this.videoHls,
      this.reviewReference,
      this.task,
      this.isPublic,
      this.videoState,
      this.coachId,
      this.coachReference,
      String id,
      Timestamp createdAt,
      String createdBy,
      Timestamp updatedAt,
      String updatedBy,
      bool isHidden,
      bool isDeleted})
      : super(id: id, createdBy: createdBy, createdAt: createdAt, updatedAt: updatedAt, updatedBy: updatedBy, isDeleted: isDeleted, isHidden: isHidden);

  factory TaskSubmission.fromJson(Map<String, dynamic> json) {
    TaskSubmission taskSubmission = TaskSubmission(
        video: json['video'] == null ? null : Video.fromJson(json['video'] as Map<String, dynamic>),
        videoHls: json['video_hls']?.toString(),
        reviewReference: json['review_reference'] as DocumentReference,
        task: json['task'] == null ? null : ObjectSubmodel.fromJson(json['task'] as Map<String, dynamic>),
        isPublic: json['is_public'] == null ? false : json['is_public'] as bool,
        coachId: json['coach_id']?.toString(),
        coachReference: json['coach_reference'] as DocumentReference,
        videoState: json['video_state'] == null ? null : VideoState.fromJson(json['video_state'] as Map<String, dynamic>));
    taskSubmission.setBase(json);
    return taskSubmission;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> taskSubmissionJson = {
      'video': video == null ? null : video.toJson(),
      'video_hls': videoHls,
      'review_reference': reviewReference,
      'task': task == null ? null : task.toJson(),
      'is_public': isPublic == null ? false : isPublic,
      'coach_id': coachId,
      'coach_reference': coachReference,
      'video_state': videoState == null ? null : videoState.toJson()
    };
    taskSubmissionJson.addEntries(super.toJson().entries);
    return taskSubmissionJson;
  }

  @override
  List<Object> get props =>
      [video, reviewReference, task, isPublic, videoState, coachId, coachReference, id, createdBy, createdAt, updatedAt, updatedBy, isDeleted, isHidden];
}
