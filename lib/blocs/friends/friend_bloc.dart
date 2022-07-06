import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/friend.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/repositories/friend_repository.dart';
import 'package:oluko_app/repositories/user_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../models/submodels/friend_model.dart';

abstract class FriendState {}

class FriendLoading extends FriendState {}

class GetFriendsSuccess extends FriendState {
  Friend friendData;
  List<UserResponse> friendUsers;
  GetFriendsSuccess({this.friendData, this.friendUsers});
}

class GetFriendsDataSuccess extends FriendState {
  List<FriendModel> friends;
  GetFriendsDataSuccess({this.friends});
}

class GetFriendSuggestionSuccess extends FriendState {
  List<UserResponse> friendSuggestionList;
  GetFriendSuggestionSuccess({this.friendSuggestionList});
}

class FriendFailure extends FriendState {
  final dynamic exception;

  FriendFailure({this.exception});
}

class FriendBloc extends Cubit<FriendState> {
  FriendBloc() : super(FriendLoading());

  void getFriendsByUserId(String userId) async {
    try {
      emit(FriendLoading());
      Friend friendData = await FriendRepository.getUserFriendsByUserId(userId);
      List<UserResponse> friendList;
      if (friendData != null) {
        friendList = await Future.wait(friendData.friends.map((friend) async => UserRepository().getById(friend.id)));
      }
      removeDuplicateAndNullFriends(friendList, friendData);
      emit(GetFriendsSuccess(friendData: friendData, friendUsers: friendList));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(FriendFailure(exception: exception));
      rethrow;
    }
  }

  void removeDuplicateAndNullFriends(List<UserResponse> friendList, Friend friendData) {
    friendList.removeWhere((friend) => friend == null);
    friendData.friends.removeWhere((friend) {
      UserResponse friendUser;
      try {
        friendUser = friendList.where((fuser) => fuser != null && fuser?.id == friend.id).first;
        if (friendUser == null) {
          return true;
        }
        return false;
      } catch (e) {
        return true;
      }
    });
    final List<FriendModel> friendDataSet = [];
    for (final friend in friendData.friends) {
      print(friend);
      if (friendDataSet.isEmpty || friendDataSet.indexWhere((element) => element.id == friend.id) == -1) {
        friendDataSet.add(friend);
      }
    }
    friendData.friends = friendDataSet;
  }

  void getUserFriendsSuggestionsByUserId(String userId) async {
    try {
      List<User> friendsSuggestionList = await FriendRepository.getUserFriendsSuggestionsByUserId(userId);
      emit(GetFriendSuggestionSuccess(friendSuggestionList: null));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(FriendFailure(exception: exception));
      rethrow;
    }
  }

  void removeFriend(String userId, Friend currentUserFriend, String userToRemoveId) async {
    try {
      await FriendRepository.removeFriendFromList(currentUserFriend, userToRemoveId);
      getFriendsByUserId(userId);
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(FriendFailure(exception: exception));
    }
  }

  void getFriendsDataByUserId(String userId) async {
    try {
      emit(FriendLoading());
      Friend friendData = await FriendRepository.getUserFriendsByUserId(userId);
      emit(GetFriendsDataSuccess(friends: friendData.friends));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(FriendFailure(exception: exception));
      rethrow;
    }
  }
}
