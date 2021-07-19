import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/base.dart';
import 'package:oluko_app/models/submodels/video.dart';

class MovementSubmission extends Base {
  String userId;
  DocumentReference userReference;
  String movementId;
  DocumentReference movementReference;
  Timestamp seenAt;
  Video video;

  MovementSubmission(
      {this.userId,
      this.userReference,
      this.movementId,
      this.movementReference,
      this.seenAt,
      this.video,
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
        movementId: json['movement_id'],
        movementReference: json['movement_reference'],
        video:
            json['coach_id'] == null ? null : Video.fromJson(json['coach_id']));
    movementSubmission.setBase(json);
    return movementSubmission;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> movementSubmissionJson = {
      'user_id': userId,
      'user_reference': userReference,
      'movement_id': movementId,
      'movement_reference': movementReference,
      'seen_at': seenAt,
      'video': video == null ? null : video.toJson()
    };
    movementSubmissionJson.addEntries(super.toJson().entries);
    return movementSubmissionJson;
  }
}
