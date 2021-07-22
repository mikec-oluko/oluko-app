import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/base.dart';
import 'package:oluko_app/models/submodels/video.dart';
import 'package:oluko_app/models/submodels/video_state.dart';

class MovementSubmission extends Base {
  String userId;
  DocumentReference userReference;
  String movementId;
  DocumentReference movementReference;
  Timestamp seenAt;
  Video video;
  VideoState videoState;
  String segmentSubmissionId;
  DocumentReference segmentSubmissionReference;

  MovementSubmission(
      {this.userId,
      this.userReference,
      this.movementId,
      this.movementReference,
      this.seenAt,
      this.video,
      this.videoState,
      this.segmentSubmissionId,
      this.segmentSubmissionReference,
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

  factory MovementSubmission.fromJson(Map<String, dynamic> json) {
    MovementSubmission movementSubmission = MovementSubmission(
        userId: json['user_id'],
        userReference: json['user_reference'],
        segmentSubmissionId: json['segment_submission_id'],
        segmentSubmissionReference: json['segment_submission_reference'],
        movementId: json['movement_id'],
        movementReference: json['movement_reference'],
        video: json['video'] == null ? null : Video.fromJson(json['video']),
        videoState: json['video_state'] == null
            ? null
            : VideoState.fromJson(json['video_state']));
    movementSubmission.setBase(json);
    return movementSubmission;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> movementSubmissionJson = {
      'user_id': userId,
      'user_reference': userReference,
      'segment_submission_id': segmentSubmissionId,
      'segment_submission_reference': segmentSubmissionReference,
      'movement_id': movementId,
      'movement_reference': movementReference,
      'seen_at': seenAt,
      'video': video == null ? null : video.toJson(),
      'video_state': videoState == null ? null : videoState.toJson()
    };
    movementSubmissionJson.addEntries(super.toJson().entries);
    return movementSubmissionJson;
  }
}
