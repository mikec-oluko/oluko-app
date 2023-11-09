import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
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

class CoachAssignmentResponseDispose extends CoachAssignmentState {
  CoachAssignmentResponseDispose({this.coachAssignmentDisposeValue});
  final CoachAssignment coachAssignmentDisposeValue;
}

class CoachAssignmentBloc extends Cubit<CoachAssignmentState> {
  CoachAssignmentBloc() : super(Loading());
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>> subscription;
  @override
  void dispose() {
    if (subscription != null) {
      subscription.cancel();
      subscription = null;
    }
    emitCoachAssignmentDispose();
  }

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

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>> getCoachAssignmentStatusStream(String userId) {
    CoachAssignment coachAssignmentResponse;
    return subscription ??= CoachRepository.getCoachAssignmentByUserIdStream(userId).listen((snapshot) async {
      try {
        snapshot.docs.forEach((doc) {
          final Map<String, dynamic> content = doc.data();
          coachAssignmentResponse = CoachAssignment.fromJson(content);
        });
        emit(CoachAssignmentResponse(coachAssignmentResponse: coachAssignmentResponse));
      } catch (exception, stackTrace) {
        await Sentry.captureException(
          exception,
          stackTrace: stackTrace,
        );
        emit(CoachAssignmentFailure(exception: exception));
        rethrow;
      }
    });
  }

  void welcomeVideoAsSeen(CoachAssignment coachAssignment) async {
    try {
      final CoachAssignment coachAssignmentUpdated = await CoachRepository().welcomeVideoMarkAsSeen(coachAssignment);
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

  void introductionVideoAsSeen(String userId) async {
    try {
      final CoachAssignment coachAssignmentUpdated = await CoachRepository().introductionVideoMarkAsSeen(userId);
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

  void emitCoachAssignmentDispose() async {
    try {
      emit(CoachAssignmentResponseDispose());
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
