import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/challenge.dart';
import 'package:oluko_app/repositories/challenge_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class ChallengeCompletedBeforeState {}

class Loading extends ChallengeCompletedBeforeState {}

class Failure extends ChallengeCompletedBeforeState {
  final dynamic exception;
  Failure({this.exception});
}

class ChallengeHistoricalResult extends ChallengeCompletedBeforeState {
  final bool wasCompletedBefore;
  ChallengeHistoricalResult({this.wasCompletedBefore});
}

class ChallengeCompletedBeforeBloc extends Cubit<ChallengeCompletedBeforeState> {
  ChallengeCompletedBeforeBloc() : super(Loading());

  Future<void> completedChallengeBefore({@required String segmentId, @required String userId}) async {
    bool _completedBefore = false;
    try {
      if (segmentId != null && userId != null) {
        final List<Challenge> challenges = await ChallengeRepository.getUserChallengesBySegmentId(segmentId, userId);
        if (challenges == null) {
          emit(ChallengeHistoricalResult(wasCompletedBefore: false));
        } else {
          if (challenges.where((element) => element.completedAt != null).toList().isNotEmpty) {
            _completedBefore = true;
          }
          emit(ChallengeHistoricalResult(wasCompletedBefore: _completedBefore));
        }
      } else {
        emit(ChallengeHistoricalResult(wasCompletedBefore: false));
      }
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(Failure(exception: exception));
      rethrow;
    }
  }

  Future<bool> checkChallengeWasCompleted({@required String segmentId, @required String userId}) async {
    bool _completedBefore = false;
    try {
      if (segmentId != null && userId != null) {
        final List<Challenge> challenges = await ChallengeRepository.getUserChallengesBySegmentId(segmentId, userId);
        if (challenges == null) {
          _completedBefore = false;
        } else {
          if (challenges.where((element) => element.completedAt != null).toList().isNotEmpty) {
            _completedBefore = true;
          }
        }
      } else {
        _completedBefore = false;
      }
      return _completedBefore;
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
