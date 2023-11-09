import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/challenge.dart';
import 'package:oluko_app/repositories/challenge_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class ChallengeSegmentState {}

class Loading extends ChallengeSegmentState {}

class Failure extends ChallengeSegmentState {
  final dynamic exception;
  Failure({this.exception});
}

class ChallengesSuccess extends ChallengeSegmentState {
  final List<Challenge> challenges;
  ChallengesSuccess({this.challenges});
}

class ChallengeSegmentBloc extends Cubit<ChallengeSegmentState> {
  ChallengeSegmentBloc() : super(Loading());

  void getByClass(String courseEnrollmentId, String classId) async {
    try {
      final List<Challenge> challenges = await ChallengeRepository.getByClass(courseEnrollmentId, classId);
      emit(ChallengesSuccess(challenges: challenges));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(Failure(exception: exception));
      rethrow;
    }
  }

  Future<bool> isNewPersonalRecord(String segmentId, String userId, int result) async {
    try {
      final List<Challenge> challenges = await ChallengeRepository.getUserChallengesBySegmentId(segmentId, userId);
      bool isNewPR = true;
      for (final challenge in challenges) {
        if (challenge.result != null) {
          final actualResult = int.tryParse(challenge.result);
          if (actualResult != null && actualResult > result) {
            isNewPR = false;
          }
        }
      }
      return isNewPR;
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      return false;
    }
  }
}
