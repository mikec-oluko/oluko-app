import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/assessment_assignment.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/repositories/assessment_assignment_repository.dart';
import 'package:oluko_app/repositories/auth_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class AssessmentVisibilityState {}

class AssessmentVisibilityLoading extends AssessmentVisibilityState {}

class UnSeenAssignmentSuccess extends AssessmentVisibilityState {
  final UserResponse user;
  UnSeenAssignmentSuccess({this.user});
}

class AssessmentVisibilityFailure extends AssessmentVisibilityState {
  final dynamic exception;
  AssessmentVisibilityFailure({this.exception});
}

class SeenAssignmentSuccess extends AssessmentVisibilityState {
  SeenAssignmentSuccess();
}

class AssessmentVisibilityDefault extends AssessmentVisibilityState {
  AssessmentVisibilityDefault();
}

class AssessmentVisibilityBloc extends Cubit<AssessmentVisibilityState> {
  AssessmentVisibilityBloc() : super(AssessmentVisibilityLoading());

  void assignmentSeen(String userId) async {
    try {
      final AssessmentAssignment assessmentA = await AssessmentAssignmentRepository.getByUserId(userId);
      final UserResponse loggedUserResponse = await AuthRepository().retrieveLoginData();
      if (assessmentA != null && (assessmentA.seenByUser == null || !assessmentA.seenByUser)) {
        emit(UnSeenAssignmentSuccess(user: loggedUserResponse));
      } else {
        emit(SeenAssignmentSuccess());
      }
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(AssessmentVisibilityFailure(exception: exception));
      rethrow;
    }
  }

  Future<void> setAsSeen(String userId) async {
    try {
      await AssessmentAssignmentRepository.setAsSeen(userId);
      emit(SeenAssignmentSuccess());
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(AssessmentVisibilityFailure(exception: exception));
      rethrow;
    }
  }

  void setAssessmentVisibilityDefaultState() {
    emit(AssessmentVisibilityDefault());
  }
}
