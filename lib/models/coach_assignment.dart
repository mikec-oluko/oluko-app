import 'package:cloud_firestore/cloud_firestore.dart';
import 'base.dart';

class CoachAssignment extends Base {
  CoachAssignment(
      {this.userId,
      this.coachId,
      this.coachReference,
      this.coachAssignmentStatus,
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

  factory CoachAssignment.fromJson(Map<String, dynamic> json) {
    CoachAssignment coachAssignmentObject = CoachAssignment(
        userId: json['id'] as String,
        coachId: json['coach_id'] as String,
        coachReference: json['coach_reference'] as DocumentReference,
        coachAssignmentStatus: json['status'] as num);
    coachAssignmentObject.setBase(json);
    return coachAssignmentObject;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> coachAssignmentJson = {
      'id': userId,
      'coach_id': coachId,
      'coach_reference': coachReference,
      'status': coachAssignmentStatus
    };
    coachAssignmentJson.addEntries(super.toJson().entries);
    return coachAssignmentJson;
  }
}
