import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/base.dart';
import 'package:oluko_app/models/submodels/object_submodel.dart';

class SegmentSubmission extends Base {
  String segmentId;
  DocumentReference segmentReference;
  String userId;
  DocumentReference userReference;
  String courseEnrollmentId;
  DocumentReference courseEnrollmentReference;
  String coachId;
  DocumentReference coachReference;
  Timestamp seenAt;
  List<ObjectSubmodel> movementSubmissions;

  SegmentSubmission(
      {this.segmentId,
      this.segmentReference,
      this.userId,
      this.userReference,
      this.coachId,
      this.coachReference,
      this.courseEnrollmentId,
      this.courseEnrollmentReference,
      this.movementSubmissions,
      this.seenAt,
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

  factory SegmentSubmission.fromJson(Map<String, dynamic> json) {
    SegmentSubmission segmentSubmission = SegmentSubmission(
        userId: json['user_id'],
        userReference: json['user_reference'],
        segmentId: json['segment_id'],
        segmentReference: json['segment_reference'],
        coachId: json['coach_id'],
        coachReference: json['coach_reference'],
        courseEnrollmentId: json['course_enrollment_id'],
        courseEnrollmentReference: json['course_enrollment_reference'],
        seenAt: json['seen_at'],
        movementSubmissions: json['movement_submissions'] == null
            ? null
            : List<ObjectSubmodel>.from(json['movement_submissions']
                .map((movement) => ObjectSubmodel.fromJson(movement))));
    segmentSubmission.setBase(json);
    return segmentSubmission;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> segmentSubmissionJson = {
      'user_id': userId,
      'user_reference': userReference,
      'segment_id': segmentId,
      'segment_reference': segmentReference,
      'coach_id': coachId,
      'coach_reference': coachReference,
      'course_enrollment_id': courseEnrollmentId,
      'course_enrollment_reference': courseEnrollmentReference,
      'seen_at': seenAt,
      'movement_submissions': movementSubmissions == null
          ? null
          : List<dynamic>.from(
              movementSubmissions.map((movement) => movement.toJson()))
    };
    segmentSubmissionJson.addEntries(super.toJson().entries);
    return segmentSubmissionJson;
  }
}
