import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/assessment.dart';
import 'package:oluko_app/models/assessment_assignment.dart';
import 'package:oluko_app/repositories/assessment_assignment_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class AssessmentAssignmentState {}

class AssessmentAssignmentLoading extends AssessmentAssignmentState {}

class AssessmentAssignmentSuccess extends AssessmentAssignmentState {
  final AssessmentAssignment assessmentAssignment;
  AssessmentAssignmentSuccess({this.assessmentAssignment});
}

class AssessmentAssignmentFailure extends AssessmentAssignmentState {
  final dynamic exception;

  AssessmentAssignmentFailure({this.exception});
}

class AssessmentAssignmentBloc extends Cubit<AssessmentAssignmentState> {
  AssessmentAssignmentBloc() : super(AssessmentAssignmentLoading());

  void getOrCreate(String userId, Assessment assessment) async {
    if (!(state is AssessmentAssignmentSuccess)) {
      emit(AssessmentAssignmentLoading());
    }
    try {
      AssessmentAssignment assessmentA = await AssessmentAssignmentRepository.getByUserId(userId);
      assessmentA ??= AssessmentAssignmentRepository.create(userId, assessment);
      emit(AssessmentAssignmentSuccess(assessmentAssignment: assessmentA));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(AssessmentAssignmentFailure(exception: exception));
      rethrow;
    }
  }

  void setAsSeen(String userId) async {
    try {
      await AssessmentAssignmentRepository.setAsSeen(userId);
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(AssessmentAssignmentFailure(exception: exception));
      rethrow;
    }
  }
}
