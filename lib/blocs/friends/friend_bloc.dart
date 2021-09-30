import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/friend.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/repositories/friend_repository.dart';
import 'package:oluko_app/repositories/user_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class FriendState {}

class FriendLoading extends FriendState {}

class GetFriendsSuccess extends FriendState {
  Friend friendData;
  List<UserResponse> friendUsers;
  GetFriendsSuccess({this.friendData, this.friendUsers});
}

class GetFriendRequestsSuccess extends FriendState {
  List<UserResponse> friendRequestList;
  Friend friendData;
  GetFriendRequestsSuccess({this.friendRequestList, this.friendData});
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
      Friend friendData = await FriendRepository.getUserFriendsByUserId(userId);
      List<UserResponse> friendList;
      if (friendData != null) {
        friendList = await Future.wait(friendData.friends.map((friend) async => UserRepository().getById(friend.id)));
      }
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

  void getUserFriendsRequestByUserId(String userId) async {
    try {
      Friend friendInformation = await FriendRepository.getUserFriendsRequestByUserId(userId);

      if (friendInformation != null) {
        List<UserResponse> friendRequestUsers =
            await Future.wait(friendInformation.friendRequestReceived.map((e) => UserRepository().getById(e.id)).toList());

        emit(GetFriendRequestsSuccess(friendData: friendInformation, friendRequestList: friendRequestUsers));
      } else {
        emit(GetFriendRequestsSuccess(friendData: null, friendRequestList: []));
      }
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(FriendFailure(exception: exception));
      rethrow;
    }
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

  void removeRequestSent(String userId, Friend currentUserFriend, String userRequestedId) async {
    try {
      await FriendRepository.removeRequestSent(currentUserFriend, userRequestedId);
      getFriendsByUserId(userId);
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(FriendFailure(exception: exception));
      rethrow;
    }
  }

  void sendRequestOfConnect(String userId, Friend currentUserFriend, String userRequestedId) async {
    try {
      await FriendRepository.sendRequestOfConnectOnBothUsers(currentUserFriend, userRequestedId);
      getFriendsByUserId(userId);
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(FriendFailure(exception: exception));
      rethrow;
    }
  }

  void removeFriend(Friend currentUserFriend, String userToRemoveId) async {
    try {
      await FriendRepository.removeFriendFromList(currentUserFriend, userToRemoveId);
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(FriendFailure(exception: exception));
    }
  }
}
