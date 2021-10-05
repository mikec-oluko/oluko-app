import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/coach_request.dart';
import 'package:oluko_app/repositories/coach_request_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class CoachRequestState {}

class CoachRequestLoading extends CoachRequestState {}

class CoachRequestSuccess extends CoachRequestState {
  final List<CoachRequest> values;
  CoachRequestSuccess({this.values});
}

class GetCoachRequestSuccess extends CoachRequestState {
  final CoachRequest coachRequest;
  GetCoachRequestSuccess({this.coachRequest});
}

class CoachRequestFailure extends CoachRequestState {
  final dynamic exception;

  CoachRequestFailure({this.exception});
}

class CoachRequestBloc extends Cubit<CoachRequestState> {
  CoachRequestBloc() : super(CoachRequestLoading());

  void get(String userId) async {
    if (!(state is CoachRequestSuccess)) {
      emit(CoachRequestLoading());
    }
    try {
      List<CoachRequest> requests = await CoachRequestRepository().get(userId);
      emit(CoachRequestSuccess(values: requests));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(CoachRequestFailure(exception: exception));
      rethrow;
    }
  }

  void getBySegment(
      String userId, String segmentId, String courseEnrollmentId) async {
    if (!(state is CoachRequestSuccess)) {
      emit(CoachRequestLoading());
    }
    try {
      CoachRequest coachRequest = await CoachRequestRepository()
          .getBySegment(userId, segmentId, courseEnrollmentId);
      emit(GetCoachRequestSuccess(coachRequest: coachRequest));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(CoachRequestFailure(exception: exception));
      rethrow;
    }
  }
}
