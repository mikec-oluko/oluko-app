import 'package:cloud_firestore/cloud_firestore.dart';
import 'base.dart';

class AssessmentAssignment extends Base {
  Timestamp completedAt;
  Timestamp seenAt;
  String assessmentId;
  DocumentReference assessmentReference;
  String userId;
  DocumentReference userReference;
  String coachId;
  DocumentReference coachReference;

  AssessmentAssignment(
      {this.completedAt,
      this.seenAt,
      this.assessmentId,
      this.assessmentReference,
      this.userId,
      this.userReference,
      this.coachId,
      this.coachReference,
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
      completedAt: json['completed_at'],
      seenAt: json['seen_at'],
      assessmentId: json['assessment_id'],
      assessmentReference: json['assessment_reference'],
      userId: json['user_id'],
      userReference: json['user_reference'],
      coachId: json['coach_id'],
      coachReference: json['coach_reference'],
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
      'user_id': userId,
      'user_reference': userReference,
      'coach_id': coachId,
      'coach_reference': coachReference,
    };
    assessmentAssignmentJson.addEntries(super.toJson().entries);
    return assessmentAssignmentJson;
  }
}
