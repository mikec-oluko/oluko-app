import 'package:cloud_firestore/cloud_firestore.dart';
import 'base.dart';

class CoachAssignment extends Base {
  CoachAssignment(
      {this.userId,
      this.coachId,
      this.coachReference,
      this.coachAssignmentStatus,
      this.introductionCompleted,
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

  String userId, coachId;
  DocumentReference coachReference;
  num coachAssignmentStatus;
  bool introductionCompleted;

  factory CoachAssignment.fromJson(Map<String, dynamic> json) {
    CoachAssignment coachAssignmentObject = CoachAssignment(
      userId: json['id'] as String,
      coachId: json['coach_id'] as String,
      coachReference: json['coach_reference'] as DocumentReference,
      coachAssignmentStatus: json['status'] as num,
      introductionCompleted: json['introduction_completed'] == null ? false : json['introduction_completed'] as bool,
    );
    coachAssignmentObject.setBase(json);
    return coachAssignmentObject;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> coachAssignmentJson = {
      'id': userId,
      'coach_id': coachId,
      'coach_reference': coachReference,
      'status': coachAssignmentStatus,
      'introduction_completed': introductionCompleted ?? false
    };
    coachAssignmentJson.addEntries(super.toJson().entries);
    return coachAssignmentJson;
  }
}
