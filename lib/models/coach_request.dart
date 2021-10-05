import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/base.dart';

import 'enums/request_status_enum.dart';

class CoachRequest extends Base {
  RequestStatusEnum status;
  String segmentId;
  DocumentReference segmentReference;
  String coachId;
  DocumentReference coachReference;
  String segmentSubmissionId;
  DocumentReference segmentSubmissionReference;
  String courseEnrolledId;
  DocumentReference courseEnrolledReference;

  CoachRequest(
      {this.status,
      this.segmentId,
      this.segmentReference,
      this.coachId,
      this.coachReference,
      this.segmentSubmissionId,
      this.segmentSubmissionReference,
      this.courseEnrolledId,
      this.courseEnrolledReference,
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

  factory CoachRequest.fromJson(Map<String, dynamic> json) {
    final CoachRequest coachRequest = CoachRequest(
        status: RequestStatusEnum.values[json['status'] as int],
        segmentId: json['segment_id']?.toString(),
        segmentReference: json['segment_reference'] != null ? json['segment_reference'] as DocumentReference : null,
        coachId: json['coach_id']?.toString(),
        coachReference: json['coach_reference'] != null ? json['coach_reference'] as DocumentReference : null,
        segmentSubmissionId: json['segment_submission_id']?.toString(),
        segmentSubmissionReference:
            json['segment_submission_reference'] != null ? json['segment_submission_reference'] as DocumentReference : null,
        courseEnrolledId: json['course_enrolled_id']?.toString(),
        courseEnrolledReference: json['course_enrolled_reference'] != null ? json['course_enrolled_reference'] as DocumentReference : null);
    coachRequest.setBase(json);
    return coachRequest;
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> coachRequestJson = {
      'status': status,
      'segment_id': segmentId,
      'segment_reference': segmentReference,
      'coach_id': coachId,
      'coach_reference': coachReference,
      'segment_submission_id': segmentSubmissionId,
      'segment_submission_reference': segmentSubmissionReference,
      'course_enrolled_id': courseEnrolledId,
      'course_enrolled_reference': courseEnrolledReference,
    };
    coachRequestJson.addEntries(super.toJson().entries);
    return coachRequestJson;
  }
}