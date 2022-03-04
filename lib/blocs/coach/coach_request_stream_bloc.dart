import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/coach_request.dart';
import 'package:oluko_app/models/enums/request_status_enum.dart';
import 'package:oluko_app/repositories/coach_request_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class CoachRequestStreamState {}

class CoachRequestStreamLoading extends CoachRequestStreamState {}

class CoachRequestStreamSuccess extends CoachRequestStreamState {
  final List<CoachRequest> values;
  CoachRequestStreamSuccess({this.values});
}

class ClassCoachRequestsStreamSuccess extends CoachRequestStreamState {
  final List<CoachRequest> coachRequests;
  ClassCoachRequestsStreamSuccess({this.coachRequests});
}

class ResolveSuccess extends CoachRequestStreamState {
  ResolveSuccess();
}

class GetCoachRequestStreamSuccess extends CoachRequestStreamState {
  final CoachRequest coachRequest;
  GetCoachRequestStreamSuccess({this.coachRequest});
}

class GetCoachRequestStreamDispose extends CoachRequestStreamState {
  final List<CoachRequest> coachRequestDisposeValue;
  GetCoachRequestStreamDispose({this.coachRequestDisposeValue});
}

class GetCoachRequestStreamUpdate extends CoachRequestStreamState {
  final List<CoachRequest> values;
  GetCoachRequestStreamUpdate({this.values});
}

class CoachRequestStreamFailure extends CoachRequestStreamState {
  final dynamic exception;

  CoachRequestStreamFailure({this.exception});
}

class CoachRequestStreamBloc extends Cubit<CoachRequestStreamState> {
  final CoachRequestRepository _coachRequestRepository = CoachRequestRepository();
  CoachRequestStreamBloc() : super(CoachRequestStreamLoading());
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>> subscription;
  @override
  void dispose() {
    if (subscription != null) {
      subscription.cancel();
      subscription = null;
      emitCoachRequestDispose();
    }
  }

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>> getStream(String userId, String coachId) {
    subscription ??= _coachRequestRepository.getCoachRequestSubscription(userId, coachId).listen((snapshot) async {
      Set<CoachRequest> coachRequests = Set();
      Set<CoachRequest> coachRequestsUpdated = Set();
      Set<CoachRequest> coachRequestsUpdateContent = Set();

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

      if (coachRequestsUpdated.length > 0) {
        coachRequestsUpdateContent.addAll(coachRequests);
        coachRequestsUpdated.forEach((requestUpdatedItem) {
          coachRequestsUpdateContent.forEach((requestItem) {
            requestUpdatedItem.id == requestItem.id
                ? requestUpdatedItem != requestItem
                    ? requestItem = requestUpdatedItem
                    : null
                : null;
          });
        });
      } else {
        coachRequestsUpdateContent.addAll(coachRequestsUpdated);
      }

      coachRequestsUpdateContent.isNotEmpty
          ? emit(GetCoachRequestStreamUpdate(values: coachRequestsUpdateContent.toList()))
          : emit(CoachRequestStreamSuccess(values: coachRequests.toList()));
    });
    return subscription;
  }

  void get(String userId) async {
    if (!(state is CoachRequestStreamSuccess)) {
      emit(CoachRequestStreamLoading());
    }
    try {
      List<CoachRequest> requests = await _coachRequestRepository.get(userId);
      emit(CoachRequestStreamSuccess(values: requests));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(CoachRequestStreamFailure(exception: exception));
      rethrow;
    }
  }

  void resolve(CoachRequest coachRequest, String userId, RequestStatusEnum requestStatus) async {
    if (coachRequest == null) {
      return;
    }
    try {
      await _coachRequestRepository.resolve(coachRequest, userId, requestStatus);
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(CoachRequestStreamFailure(exception: exception));
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
      emit(CoachRequestStreamFailure(exception: exception));
      rethrow;
    }
  }

  void emitCoachRequestDispose() async {
    try {
      emit(GetCoachRequestStreamDispose(coachRequestDisposeValue: []));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(CoachRequestStreamFailure(exception: exception));
      rethrow;
    }
  }
}
