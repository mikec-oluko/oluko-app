import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/base.dart';
import 'package:oluko_app/models/submodels/video.dart';

class MovementSubmission extends Base {
  String userId;
  DocumentReference userReference;
  Timestamp seenAt;
  Video video;

  MovementSubmission(
      {this.userId,
      this.userReference,
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
        video: Video.fromJson(json['coach_id']));
    movementSubmission.setBase(json);
    return movementSubmission;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> movementSubmissionJson = {
      'user_id': userId,
      'user_reference': userReference,
      'seen_at': seenAt,
      'video': video.toJson()
    };
    movementSubmissionJson.addEntries(super.toJson().entries);
    return movementSubmissionJson;
  }
}
