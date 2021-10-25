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

class ResolveSuccess extends CoachRequestState {
  ResolveSuccess();
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

  void getSegmentCoachRequest({String userId, String segmentId, String coachId, String courseEnrollmentId}) async {
    emit(CoachRequestLoading());
    try {
      CoachRequest coachRequest =
          await CoachRequestRepository().getBySegmentAndCoachId(userId, segmentId, courseEnrollmentId, coachId);
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

  void resolve(CoachRequest coachRequest, String userId) async {
    try {
      await CoachRequestRepository().resolve(coachRequest, userId);
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
