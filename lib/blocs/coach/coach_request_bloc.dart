import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/coach_request.dart';
import 'package:oluko_app/models/enums/request_status_enum.dart';
import 'package:oluko_app/repositories/coach_request_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class CoachRequestState {}

class CoachRequestLoading extends CoachRequestState {}

class CoachRequestSuccess extends CoachRequestState {
  final List<CoachRequest> values;
  CoachRequestSuccess({this.values});
}

class ClassCoachRequestsSuccess extends CoachRequestState {
  final List<CoachRequest> coachRequests;
  ClassCoachRequestsSuccess({this.coachRequests});
}

class ResolveSuccess extends CoachRequestState {
  ResolveSuccess();
}

class GetCoachRequestSuccess extends CoachRequestState {
  final CoachRequest coachRequest;
  GetCoachRequestSuccess({this.coachRequest});
}

class GetCoachRequestDispose extends CoachRequestState {
  final List<CoachRequest> coachRequestDisposeValue;
  GetCoachRequestDispose({this.coachRequestDisposeValue});
}

class GetCoachRequestUpdate extends CoachRequestState {
  final List<CoachRequest> values;
  GetCoachRequestUpdate({this.values});
}

class CoachRequestFailure extends CoachRequestState {
  final dynamic exception;

  CoachRequestFailure({this.exception});
}

class CoachRequestBloc extends Cubit<CoachRequestState> {
  final CoachRequestRepository _coachRequestRepository = CoachRequestRepository();
  CoachRequestBloc() : super(CoachRequestLoading());

  @override
  void dispose() {}

  void get(String userId) async {
    if (!(state is CoachRequestSuccess)) {
      emit(CoachRequestLoading());
    }
    try {
      List<CoachRequest> requests = await _coachRequestRepository.get(userId);
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

  void getSegmentCoachRequest({String userId, String segmentId, String coachId, String courseEnrollmentId, String classId}) async {
    emit(CoachRequestLoading());
    try {
      CoachRequest coachRequest =
          await _coachRequestRepository.getBySegmentAndCoachId(userId, segmentId, courseEnrollmentId, coachId, classId);
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

  void resolve(CoachRequest coachRequest, String userId, RequestStatusEnum requestStatus) async {
    try {
      await _coachRequestRepository.resolve(coachRequest, userId, requestStatus);
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(CoachRequestFailure(exception: exception));
      rethrow;
    }
  }

  void setRequestSegmentNotificationAsViewed(String coachRequestId, String userId, bool notificationValue) async {
    try {
      await _coachRequestRepository.updateNotificationStatus(coachRequestId, userId, notificationValue);
      get(userId); //TODO: check if needed
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(CoachRequestFailure(exception: exception));
      rethrow;
    }
  }

  void getClassCoachRequest({String userId, String classId, String coachId, String courseEnrollmentId}) async {
    emit(CoachRequestLoading());
    try {
      List<CoachRequest> coachRequests = await _coachRequestRepository.getByClassAndCoach(userId, classId, courseEnrollmentId, coachId);
      emit(ClassCoachRequestsSuccess(coachRequests: coachRequests));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(CoachRequestFailure(exception: exception));
      rethrow;
    }
  }

  void emitCoachRequestDispose() async {
    try {
      emit(GetCoachRequestDispose(coachRequestDisposeValue: []));
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
