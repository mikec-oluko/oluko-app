import 'package:cloud_firestore/cloud_firestore.dart';
import 'base.dart';

class AssessmentAssignment extends Base {
  Timestamp compleatedAt;
  Timestamp seenAt;
  String assessmentId;
  DocumentReference assessmentReference;
  String coachId;
  DocumentReference coachReference;

  AssessmentAssignment(
      {this.compleatedAt,
      this.seenAt,
      this.assessmentId,
      this.assessmentReference,
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
      compleatedAt: json['compleated_at'] as Timestamp,
      seenAt: json['seen_at'] as Timestamp,
      assessmentId: json['assessment_id'].toString(),
      assessmentReference: json['assessment_reference'] as DocumentReference,
      coachId: json['coach_id'].toString(),
      coachReference: json['coach_reference'] as DocumentReference,
    );
    assessmentAssignment.setBase(json);
    return assessmentAssignment;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> assessmentAssignmentJson = {
      'compleated_at': compleatedAt,
      'seen_at': seenAt,
      'assessment_id': assessmentId,
      'assessment_reference': assessmentReference,
      'coach_id': coachId,
      'coach_reference': coachReference,
    };
    assessmentAssignmentJson.addEntries(super.toJson().entries);
    return assessmentAssignmentJson;
  }
}
