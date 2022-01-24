import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/challenge.dart';
import 'package:oluko_app/models/dto/user_stories.dart';
import 'package:oluko_app/models/friend.dart';
import 'package:oluko_app/models/submodels/friend_model.dart';
import 'package:oluko_app/models/submodels/user_submodel.dart';
import 'package:oluko_app/repositories/challenge_repository.dart';
import 'package:oluko_app/repositories/friend_repository.dart';
import 'package:oluko_app/repositories/story_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class DoneChallengeUsersState {}

class DoneChallengeUsersLoading extends DoneChallengeUsersState {}

class DoneChallengeUsersSuccess extends DoneChallengeUsersState {
  final List<UserSubmodel> users;
  final List<UserSubmodel> favoriteUsers;
  final int occurrencesInClasses;
  DoneChallengeUsersSuccess({this.users, this.favoriteUsers, this.occurrencesInClasses});
}

class DoneChallengeUsersFailure extends DoneChallengeUsersState {
  final dynamic exception;
  DoneChallengeUsersFailure({this.exception});
}

class DoneChallengeUsersBloc extends Cubit<DoneChallengeUsersState> {
  DoneChallengeUsersBloc() : super(DoneChallengeUsersLoading());
  void get(String segmentId, String userId) async {
    try {
      emit(DoneChallengeUsersLoading());
      final List<Challenge> challengesList = await ChallengeRepository.getBySegmentId(segmentId);

      List<UserSubmodel> uniqueUserList = [];
      List<String> uniqueChallengeList = [];
      List<UserSubmodel> favoriteUserList = [];
      if (challengesList != null) {
        challengesList.forEach((challenge) {
          if (challenge.user != null &&
              challenge.completedAt != null &&
              !uniqueUserList.any((element) => element.id == challenge.user.id)) {
            uniqueUserList.add(challenge.user);
          }
          if (!uniqueChallengeList.any((element) => element == challenge.classId)) {
            uniqueChallengeList.add(challenge.classId);
          }
        });

        final Friend friendData = await FriendRepository.getUserFriendsByUserId(userId);
        final List<FriendModel> friends = friendData?.friends;

        if (friends != null) {
          for (final friend in friends) {
            if (friend.isFavorite) {
              final index = uniqueUserList.map((user) => user.id).toList().indexOf(friend.id);
              if (index != -1) {
                final user = uniqueUserList[index];
                final stories = await StoryRepository.getByUserId(user.id);
                final UserStories userStories = UserStories(
                    avatar: user.avatar, avatar_thumbnail: user.avatarThumbnail, id: user.id, name: user.firstName, stories: stories);
                user.stories = userStories;
                uniqueUserList.removeAt(index);
                favoriteUserList.add(user);
              }
            }
          }
        }
      }
      emit(DoneChallengeUsersSuccess(
          users: uniqueUserList, favoriteUsers: favoriteUserList, occurrencesInClasses: uniqueChallengeList.length));
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
