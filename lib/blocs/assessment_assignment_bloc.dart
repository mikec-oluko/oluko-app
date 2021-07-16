import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/assessment_assignment.dart';
import 'package:oluko_app/repositories/assessment_assignment_repository.dart';

abstract class AssessmentAssignmentState {}

class AssessmentAssignmentLoading extends AssessmentAssignmentState {}

class AssessmentAssignmentSuccess extends AssessmentAssignmentState {
  final AssessmentAssignment assessmentAssignment;
  AssessmentAssignmentSuccess({this.assessmentAssignment});
}

class AssessmentAssignmentFailure extends AssessmentAssignmentState {
  final Exception exception;

  AssessmentAssignmentFailure({this.exception});
}

class AssessmentAssignmentBloc extends Cubit<AssessmentAssignmentState> {
  AssessmentAssignmentBloc() : super(AssessmentAssignmentLoading());

  void getOrCreate(User user) async {
    if (!(state is AssessmentAssignmentSuccess)) {
      emit(AssessmentAssignmentLoading());
    }
    try {
      AssessmentAssignment assessmentA =
          await AssessmentAssignmentRepository.getByUserId(user.uid);
      if (assessmentA == null) {
        assessmentA = AssessmentAssignmentRepository.create(user);
      }
      emit(AssessmentAssignmentSuccess(assessmentAssignment: assessmentA));
    } catch (e) {
      emit(AssessmentAssignmentFailure(exception: e));
    }
  }
}
