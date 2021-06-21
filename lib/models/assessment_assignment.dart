import 'package:firebase_storage/firebase_storage.dart';

class AssessmentAssignment {
  AssessmentAssignment(
      {this.name,
      this.createdAt,
      this.completedAt,
      this.seenAt,
      this.assessmentId,
      this.assessmentReference,
      this.userId,
      this.userReference,
      this.coachId,
      this.coachReference});

  String name;
  DateTime createdAt;
  DateTime completedAt;
  DateTime seenAt;
  String assessmentId;
  Reference assessmentReference;
  String userId;
  Reference userReference;
  String coachId;
  Reference coachReference;

  AssessmentAssignment.fromJson(Map json)
      : name = json['name'],
        createdAt = json['created_at'],
        completedAt = json['completed_at'],
        seenAt = json['seen_at'],
        assessmentId = json['assessment_id'],
        assessmentReference = json['assessment_reference'],
        userId = json['user_id'],
        userReference = json['user_reference'],
        coachId = json['coach_id'],
        coachReference = json['coach_reference'];

  Map<String, dynamic> toJson() => {
        'name': name,
        'created_at': createdAt,
        'completed_at': completedAt,
        'seen_at': seenAt,
        'assessment_id': assessmentId,
        'assessment_reference': assessmentReference,
        'user_id': userId,
        'user_reference': userReference,
        'coach_id': coachId,
        'coach_reference': coachId
      };
}
