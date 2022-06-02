import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/helpers/challenge_navigation.dart';
import 'package:oluko_app/models/challenge.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/repositories/challenge_repository.dart';
import 'package:oluko_app/ui/components/challenges_card.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class ChallengeCompletedBeforeState {}

class LoadingChallenges extends ChallengeCompletedBeforeState {}

class Failure extends ChallengeCompletedBeforeState {
  final dynamic exception;
  Failure({this.exception});
}

class ChallengeHistoricalResult extends ChallengeCompletedBeforeState {
  final bool wasCompletedBefore;
  ChallengeHistoricalResult({this.wasCompletedBefore});
}

class ChallengeListSuccess extends ChallengeCompletedBeforeState {
  final List<Widget> challenges;
  ChallengeListSuccess({this.challenges});
}

class ChallengeCompletedBeforeBloc extends Cubit<ChallengeCompletedBeforeState> {
  ChallengeCompletedBeforeBloc() : super(LoadingChallenges());

  Future<void> completedChallengeBefore({@required String segmentId, @required String userId}) async {
    bool _completedBefore = false;
    try {
      emit(LoadingChallenges());
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

  Future<void> returnChallengeCards(
      {@required String userId,
      @required List<ChallengeNavigation> listOfChallenges,
      bool isCurrentUser = true,
      UserResponse userRequested}) async {
    List<Widget> challengesCards = [];
    try {
      emit(LoadingChallenges());
      if (listOfChallenges.isNotEmpty) {
        for (var challenge in listOfChallenges) {
          List<Challenge> challengeHistory = await ChallengeRepository.getUserChallengesBySegmentId(challenge.segmentId, userId);
          bool challengeWasCompletedBefore =
              challengeHistory != null ? challengeHistory.where((element) => element.completedAt != null).toList().isNotEmpty : false;
          challengesCards.add(ChallengesCard(
              userRequested: !isCurrentUser ? userRequested : null,
              useAudio: !isCurrentUser,
              segmentChallenge: challenge,
              navigateToSegment: isCurrentUser,
              audioIcon: !isCurrentUser,
              customValueForChallenge: challengeWasCompletedBefore));
        }
        emit(ChallengeListSuccess(challenges: challengesCards));
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

  /*Future<void> getUniqueChallengeCards(
      {@required String userId,
      @required List<ChallengeNavigation> listOfChallenges,
      bool isCurrentUser = true,
      UserResponse userRequested}) async {
    List<Widget> challengesCards = [];
    Map<String, List<ChallengeNavigation>> challengeMap = {};
    try {
      emit(LoadingChallenges());
      if (listOfChallenges.isNotEmpty) {
        for (var challenge in listOfChallenges) {
          challengeMap[challenge.segmentId].add(challenge);
        }
        for (String id in challengeMap.keys) {
          List<Challenge> challengeHistory = await ChallengeRepository.getUserChallengesBySegmentId(id, userId);
          bool challengeWasCompletedBefore =
              challengeHistory != null ? challengeHistory.where((element) => element.completedAt != null).toList().isNotEmpty : false;
          challengesCards.add(ChallengesCard(
              userRequested: !isCurrentUser ? userRequested : null,
              useAudio: !isCurrentUser,
              segmentChallenge: challenge,
              navigateToSegment: isCurrentUser,
              audioIcon: !isCurrentUser,
              customValueForChallenge: challengeWasCompletedBefore));
        }

        emit(ChallengeListSuccess(challenges: challengesCards));
      }
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(Failure(exception: exception));
      rethrow;
    }
  }*/
}
