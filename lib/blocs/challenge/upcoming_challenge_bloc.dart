import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/helpers/challenge_navigation.dart';
import 'package:oluko_app/models/challenge.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/repositories/challenge_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class UpcomingChallengesState {}

class LoadingUpcomingChallenges extends UpcomingChallengesState {}

class ChallengesDefaultState extends UpcomingChallengesState {}

class Failure extends UpcomingChallengesState {
  final dynamic exception;
  Failure({this.exception});
}

class UniqueChallengesSuccess extends UpcomingChallengesState {
  final Map<String, List<ChallengeNavigation>> challengeMap;
  final Map<String, bool> lockedChallenges;
  UniqueChallengesSuccess({this.challengeMap, this.lockedChallenges});
}

class UpcomingChallengesBloc extends Cubit<UpcomingChallengesState> {
  UpcomingChallengesBloc() : super(LoadingUpcomingChallenges());

  Future<void> getUniqueChallengeCards({
    @required String userId,
    @required List<ChallengeNavigation> listOfChallenges,
    bool isCurrentUser = true,
    UserResponse userRequested,
  }) async {
    try {
      emit(LoadingUpcomingChallenges());
      if (listOfChallenges.isEmpty) {
        return;
      }
      Map<String, List<ChallengeNavigation>> challengeMap = {};
      Map<String, bool> lockedChallenges = {};
      for (var challenge in listOfChallenges) {
        challengeMap.putIfAbsent(challenge.segmentId, () => []).add(challenge);
      }
      await Future.forEach(challengeMap.keys, (String id) async {
        List<Challenge> challengeHistory = await ChallengeRepository.getUserChallengesBySegmentId(id, userId);
        bool challengeWasCompletedBefore = challengeHistory?.any((element) => element.completedAt != null) ?? false;
        lockedChallenges[id] = challengeWasCompletedBefore;
      });
      emit(UniqueChallengesSuccess(challengeMap: challengeMap, lockedChallenges: lockedChallenges));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(Failure(exception: exception));
      rethrow;
    }
  }

  void dispose() => emit(ChallengesDefaultState());
}
