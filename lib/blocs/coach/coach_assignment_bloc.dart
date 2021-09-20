import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/coach_assignment.dart';
import 'package:oluko_app/repositories/coach_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class CoachAssignmentState {}

class Loading extends CoachAssignmentState {}

class CoachAssignmentResponse extends CoachAssignmentState {
  CoachAssignmentResponse({this.coachAssignmentResponse});
  final CoachAssignment coachAssignmentResponse;
}

class CoachAssignmentFailure extends CoachAssignmentState {
  CoachAssignmentFailure({this.exception});
  final dynamic exception;
}

class CoachAssignmentBloc extends Cubit<CoachAssignmentState> {
  CoachAssignmentBloc() : super(Loading());

  void getCoachAssignmentStatus(String userId) async {
    try {
      final CoachAssignment coachAssignmentResponse = await CoachRepository().getCoachAssignmentByUserId(userId);
      emit(CoachAssignmentResponse(coachAssignmentResponse: coachAssignmentResponse));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(CoachAssignmentFailure(exception: exception));
      rethrow;
    }
  }

  void updateIntroductionVideoState(CoachAssignment coachAssignment) async {
    try {
      final CoachAssignment coachAssignmentUpdated = await CoachRepository().updateIntroductionStatus(coachAssignment);
      emit(CoachAssignmentResponse(coachAssignmentResponse: coachAssignmentUpdated));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(CoachAssignmentFailure(exception: exception));
      rethrow;
    }
  }
}
