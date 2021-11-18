import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>> subscription;
  @override
  void dispose() {
    if (subscription != null) {
      subscription.cancel();
    }
  }

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>> getStream(String userId, String coachId) {
    subscription ??= _coachRequestRepository.getCoachRequestSubscription(userId, coachId).listen((snapshot) async {
      List<CoachRequest> coachRequests = [];
      List<CoachRequest> coachRequestsUpdated = [];
      List<CoachRequest> coachRequestsUpdateContent = [];

      if (snapshot.docChanges.isNotEmpty) {
        snapshot.docChanges.forEach((doc) {
          final Map<String, dynamic> content = doc.doc.data();
          coachRequestsUpdated.add(CoachRequest.fromJson(content));
        });
      }
      if (snapshot.docs.isNotEmpty) {
        snapshot.docs.forEach((doc) {
          final Map<String, dynamic> content = doc.data();
          coachRequests.add(CoachRequest.fromJson(content));
        });
      }

      if (coachRequestsUpdated.length >= coachRequests.length) {
        coachRequestsUpdated.forEach((requestUpdatedItem) {
          coachRequests.forEach((requestItem) {
            requestUpdatedItem.id == requestItem.id
                ? requestUpdatedItem != requestItem
                    ? coachRequestsUpdateContent.add(requestUpdatedItem)
                    : null
                : null;
          });
        });
      } else {
        coachRequestsUpdateContent.addAll(coachRequestsUpdated);
      }

      coachRequestsUpdateContent.isNotEmpty
          ? emit(GetCoachRequestUpdate(values: coachRequestsUpdateContent))
          : emit(CoachRequestSuccess(values: coachRequests));
    });
    return subscription;
  }

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

  void resolve(CoachRequest coachRequest, String userId) async {
    try {
      await _coachRequestRepository.resolve(coachRequest, userId);
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
      // get(userId);
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
