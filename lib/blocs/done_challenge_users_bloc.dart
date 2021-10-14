import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/challenge.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/friend.dart';
import 'package:oluko_app/models/submodels/friend_model.dart';
import 'package:oluko_app/models/submodels/user_submodel.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/repositories/challenge_repository.dart';
import 'package:oluko_app/repositories/course_enrollment_repository.dart';
import 'package:oluko_app/repositories/friend_repository.dart';
import 'package:oluko_app/repositories/user_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class DoneChallengeUsersState {}

class DoneChallengeUsersLoading extends DoneChallengeUsersState {}

class DoneChallengeUsersSuccess extends DoneChallengeUsersState {
  final List<UserSubmodel> users;
  final List<UserSubmodel> favoriteUsers;
  DoneChallengeUsersSuccess({this.users, this.favoriteUsers});
}

class DoneChallengeUsersFailure extends DoneChallengeUsersState {
  final dynamic exception;
  DoneChallengeUsersFailure({this.exception});
}

class DoneChallengeUsersBloc extends Cubit<DoneChallengeUsersState> {
  DoneChallengeUsersBloc() : super(DoneChallengeUsersLoading());

  void get(String segmentId, String userId) async {
    try {
      List<Challenge> challengesList = await ChallengeRepository.getBySegmentId(segmentId);

      List<UserSubmodel> uniqueUserList = [];
      List<UserSubmodel> favoriteUserList = [];
      if (challengesList != null) {

        challengesList.forEach((challenge) {
          if (!uniqueUserList.any((element) => element.id == challenge.user.id)) {
            uniqueUserList.add(challenge.user);
          }
        });

        Friend friendData = await FriendRepository.getUserFriendsByUserId(userId);
        List<FriendModel> friends = friendData.friends;

        friends.forEach((friend) {
          if (friend.isFavorite) {
            int index = uniqueUserList.map((user) => user.id).toList().indexOf(friend.id);
            favoriteUserList.add(uniqueUserList[index]);
          }
        });
      }
      uniqueUserList.removeWhere((user) => favoriteUserList.any((element) => element.id == user.id));
      emit(DoneChallengeUsersSuccess(users: uniqueUserList, favoriteUsers: favoriteUserList));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(DoneChallengeUsersFailure(exception: exception));
      rethrow;
    }
  }
}
