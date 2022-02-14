import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/challenge.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/repositories/course_enrollment_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class ChallengeStreamState {}

class Loading extends ChallengeStreamState {}

class Failure extends ChallengeStreamState {
  final dynamic exception;
  Failure({this.exception});
}

class GetChallengeStreamSuccess extends ChallengeStreamState {
  final List<Challenge> challenges;
  GetChallengeStreamSuccess({this.challenges});
}

class ChallengeStreamBloc extends Cubit<ChallengeStreamState> {
  ChallengeStreamBloc() : super(Loading());

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>> subscription;
  @override
  void dispose() {
    if (subscription != null) {
      subscription.cancel();
      subscription = null;
    }
  }

  void getStream(String userId) async {
    try {
      subscription ??= CourseEnrollmentRepository.getUserChallengesByUserIdSubscription(userId).listen((snapshot) async {
        List<Challenge> userChallenges = [];
        snapshot.docs.forEach((doc) {
          final Map<String, dynamic> content = doc.data();
          userChallenges.add(Challenge.fromJson(content));
        });
        emit(GetChallengeStreamSuccess(challenges: userChallenges));
      });
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(Failure(exception: exception));
      rethrow;
    }
  }
}
