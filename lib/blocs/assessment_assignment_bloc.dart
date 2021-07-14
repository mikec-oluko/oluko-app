import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/assessment_assignment.dart';
import 'package:oluko_app/repositories/assessment_assignment_repository.dart';

abstract class AssessmentAssignmentState {}

class AssessmentAssignmentLoading extends AssessmentAssignmentState {}

class AssessmentAssignmentSuccess extends AssessmentAssignmentState {
  final List<AssessmentAssignment> values;
  AssessmentAssignmentSuccess({this.values});
}

class AssessmentAssignmentFailure extends AssessmentAssignmentState {
  final Exception exception;

  AssessmentAssignmentFailure({this.exception});
}

class AssessmentAssignmentBloc extends Cubit<AssessmentAssignmentState> {
  AssessmentAssignmentBloc() : super(AssessmentAssignmentLoading());

  void get() async {
    if (!(state is AssessmentAssignmentSuccess)) {
      emit(AssessmentAssignmentLoading());
    }
    try {
      List<AssessmentAssignment> assessments =
          await AssessmentAssignmentRepository().getAll();
      emit(AssessmentAssignmentSuccess(values: assessments));
    } catch (e) {
      emit(AssessmentAssignmentFailure(exception: e));
    }
  }

  void getById(String id) async {
    if (!(state is AssessmentAssignmentSuccess)) {
      emit(AssessmentAssignmentLoading());
    }
    try {
      List<AssessmentAssignment> assessments =
          await AssessmentAssignmentRepository().getById(id);
      emit(AssessmentAssignmentSuccess(values: assessments));
    } catch (e) {
      emit(AssessmentAssignmentFailure(exception: e));
    }
  }

  void getByUser(String userId) async {
    if (!(state is AssessmentAssignmentSuccess)) {
      emit(AssessmentAssignmentLoading());
    }
    try {
      List<AssessmentAssignment> assessments =
          await AssessmentAssignmentRepository().getByUserId(userId);
      emit(AssessmentAssignmentSuccess(values: assessments));
    } catch (e) {
      emit(AssessmentAssignmentFailure(exception: e));
    }
  }
}
