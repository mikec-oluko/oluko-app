import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/challenge.dart';
import 'package:oluko_app/models/dto/user_stories.dart';
import 'package:oluko_app/models/friend.dart';
import 'package:oluko_app/models/submodels/friend_model.dart';
import 'package:oluko_app/models/submodels/user_submodel.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/repositories/challenge_repository.dart';
import 'package:oluko_app/repositories/friend_repository.dart';
import 'package:oluko_app/repositories/story_repository.dart';
import 'package:oluko_app/repositories/user_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class DoneChallengeUsersState {}

class DoneChallengeUsersLoading extends DoneChallengeUsersState {}

class DoneChallengeUsersSuccess extends DoneChallengeUsersState {
  final List<UserSubmodel> users;
  final List<UserSubmodel> favoriteUsers;
  final List<UserResponse> userResponseList;
  final int occurrencesInClasses;
  DoneChallengeUsersSuccess({this.users, this.favoriteUsers, this.occurrencesInClasses, this.userResponseList});
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

      final List<UserResponse> uniqueUserResponseList = [];
      List<UserSubmodel> uniqueUserSubmodelList = [];
      List<String> uniqueChallengeList = [];
      List<UserSubmodel> favoriteUserList = [];
      if (challengesList != null) {
        challengesList.forEach((challenge) {
          if (challenge.user != null && challenge.completedAt != null && !uniqueUserSubmodelList.any((element) => element.id == challenge.user.id)) {
            uniqueUserSubmodelList.add(challenge.user);
          }
          if (!uniqueChallengeList.any((element) => element == challenge.classId)) {
            uniqueChallengeList.add(challenge.classId);
          }
        });
        var promises = uniqueUserSubmodelList.map((element) async {
          final user = await UserRepository().getById(element.id);
          if (user != null) {
            uniqueUserResponseList.add(user);
          }
        });
        await Future.wait(promises);
        final Friend friendData = await FriendRepository.getUserFriendsByUserId(userId);
        final List<FriendModel> friends = friendData?.friends;

        if (friends != null) {
          for (final friend in friends) {
            if (friend.isFavorite) {
              final index = uniqueUserSubmodelList.map((user) => user.id).toList().indexOf(friend.id);
              if (index != -1) {
                final user = uniqueUserSubmodelList[index];
                final stories = await StoryRepository.getByUserId(user.id);
                final UserStories userStories =
                    UserStories(avatar: user.avatar, avatar_thumbnail: user.avatarThumbnail, id: user.id, name: user.firstName, stories: stories);
                user.stories = userStories;
                uniqueUserSubmodelList.removeAt(index);
                favoriteUserList.add(user);
              }
            }
          }
        }
      }
      emit(
        DoneChallengeUsersSuccess(
          users: uniqueUserSubmodelList,
          favoriteUsers: favoriteUserList,
          occurrencesInClasses: uniqueChallengeList.length,
          userResponseList: uniqueUserResponseList,
        ),
      );
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
