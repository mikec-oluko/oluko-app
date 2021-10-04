import 'package:oluko_app/models/coach_assignment.dart';

import 'enum_collection.dart';

class CoachAssignmentStatus {
  CoachAssignmentStatusEnum option;
  CoachAssignmentStatus({this.option, this.statusName});
  String statusName;

  static List<CoachAssignmentStatus> coachAssignmentStatusOption = [
    CoachAssignmentStatus(option: CoachAssignmentStatusEnum.requested, statusName: 'Requested'),
    CoachAssignmentStatus(option: CoachAssignmentStatusEnum.approved, statusName: 'Approved'),
    CoachAssignmentStatus(option: CoachAssignmentStatusEnum.rejected, statusName: 'Rejected'),
  ];

  static CoachAssignmentStatusEnum getCoachAssignmentStatus(int coachStatus) =>
      coachAssignmentStatusOption.elementAt(coachStatus).option;

  CoachAssignmentStatusEnum coachAssignmentResponseStatus(CoachAssignment coachAssignmentResponse) =>
      CoachAssignmentStatus.coachAssignmentStatusOption[(coachAssignmentResponse.coachAssignmentStatus as int)].option;
}
