import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/class.dart';
import 'package:oluko_app/models/friend.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/repositories/friend_repository.dart';
import 'package:oluko_app/repositories/user_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class FriendRequestState {}

class FriendRequestLoading extends FriendRequestState {}

class GetFriendRequestsSuccess extends FriendRequestState {
  List<UserResponse> friendRequestList;
  Friend friendData;
  GetFriendRequestsSuccess({this.friendRequestList, this.friendData});
}
class GetFriendsRequestSuccess extends FriendRequestState {
  Friend friendData;
  List<UserResponse> friendUsers;
  GetFriendsRequestSuccess({this.friendData, this.friendUsers});
}
class FriendRequestFailure extends FriendRequestState {
  final dynamic exception;

  FriendRequestFailure({this.exception});
}

class FriendRequestBloc extends Cubit<FriendRequestState> {
  FriendRequestBloc() : super(FriendRequestLoading());

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
      emit(FriendRequestFailure(exception: exception));
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
      emit(FriendRequestFailure(exception: exception));
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
      emit(FriendRequestFailure(exception: exception));
      rethrow;
    }
  }
    void getFriendsByUserId(String userId) async {
    try {
      Friend friendData = await FriendRepository.getUserFriendsByUserId(userId);
      List<UserResponse> friendList;
      if (friendData != null) {
        friendList = await Future.wait(friendData.friends.map((friend) async => UserRepository().getById(friend.id)));
      }
      emit(GetFriendsRequestSuccess(friendData: friendData, friendUsers: friendList));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(FriendRequestFailure(exception: exception));
      rethrow;
    }
  }

}