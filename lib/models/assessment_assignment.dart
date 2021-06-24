import 'package:cloud_firestore/cloud_firestore.dart';
import 'base.dart';

class AssessmentAssignment extends Base {
  String id;
  Timestamp completedAt;
  Timestamp seenAt;
  String assessmentId;
  DocumentReference assessmentReference;
  String userId;
  DocumentReference userReference;
  String coachId;
  DocumentReference coachReference;

  AssessmentAssignment({
    this.id,
    this.completedAt,
    this.seenAt,
    this.assessmentId,
    this.assessmentReference,
    this.userId,
    this.userReference,
    this.coachId,
    this.coachReference,
    Timestamp createdAt,
  }) : super(createdAt: createdAt);

  factory AssessmentAssignment.fromJson(Map<String, dynamic> json) {
    return AssessmentAssignment(
      id: json['id'],
      createdAt: json['created_at'],
      completedAt: json['completed_at'],
      seenAt: json['seen_at'],
      assessmentId: json['assessment_id'],
      assessmentReference: json['assessment_reference'],
      userId: json['user_id'],
      userReference: json['user_reference'],
      coachId: json['coach_id'],
      coachReference: json['coach_reference'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'created_at': createdAt == null ? createdAtSentinel : createdAt,
        'completed_at': completedAt,
        'seen_at': seenAt,
        'assessment_id': assessmentId,
        'assessment_reference': assessmentReference,
        'user_id': userId,
        'user_reference': userReference,
        'coach_id': coachId,
        'coach_reference': coachReference,
      };
}
