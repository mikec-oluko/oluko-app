import 'package:cloud_firestore/cloud_firestore.dart';
import 'base.dart';

class AssessmentAssignment extends Base {
  Timestamp completedAt;
  Timestamp seenAt;
  String assessmentId;
  DocumentReference assessmentReference;
  String coachId;
  DocumentReference coachReference;
  bool seenByUser;

  AssessmentAssignment(
      {this.completedAt,
      this.seenAt,
      this.assessmentId,
      this.assessmentReference,
      this.coachId,
      this.coachReference,
      this.seenByUser,
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

  factory AssessmentAssignment.fromJson(Map<String, dynamic> json) {
    AssessmentAssignment assessmentAssignment = AssessmentAssignment(
      completedAt: json['compleated_at'] as Timestamp,
      seenAt: json['seen_at'] as Timestamp,
      assessmentId: json['assessment_id']?.toString(),
      assessmentReference: json['assessment_reference'] as DocumentReference,
      coachId: json['coach_id']?.toString(),
      coachReference: json['coach_reference'] as DocumentReference,
      seenByUser: json['seen_by_user'] as bool,
    );
    assessmentAssignment.setBase(json);
    return assessmentAssignment;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> assessmentAssignmentJson = {
      'completed_at': completedAt,
      'seen_at': seenAt,
      'assessment_id': assessmentId,
      'assessment_reference': assessmentReference,
      'coach_id': coachId,
      'coach_reference': coachReference,
      'seen_by_user': seenByUser
    };
    assessmentAssignmentJson.addEntries(super.toJson().entries);
    return assessmentAssignmentJson;
  }
}
