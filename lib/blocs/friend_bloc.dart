import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/friend.dart';
import 'package:oluko_app/repositories/friend_repository.dart';

abstract class FriendState {}

class Loading extends FriendState {}

class GetFriendsSuccess extends FriendState {
  List<User> friendUsers;
  GetFriendsSuccess({this.friendUsers});
}

class GetFriendRequestsSuccess extends FriendState {
  List<User> friendRequestList;
  GetFriendRequestsSuccess({this.friendRequestList});
}

class GetFriendSuggestionSuccess extends FriendState {
  List<User> friendSuggestionList;
  GetFriendSuggestionSuccess({this.friendSuggestionList});
}

class Failure extends FriendState {
  final Exception exception;

  Failure({this.exception});
}

class FriendBloc extends Cubit<FriendState> {
  FriendBloc() : super(Loading());

  void getFriendsByUserId(String userId) async {
    try {
      Friend friendData = await FriendRepository.getUserFriendsByUserId(userId);
      emit(GetFriendsSuccess(friendUsers: []));
    } catch (e) {
      emit(Failure(exception: e));
    }
  }

  void getUserFriendsRequestByUserId(String userId) async {
    try {
      List<User> friendsRequests =
          await FriendRepository.getUserFriendsRequestByUserId(userId);
      emit(GetFriendRequestsSuccess(friendRequestList: friendsRequests));
    } catch (e) {
      emit(Failure(exception: e));
    }
  }

  void getUserFriendsSuggestionsByUserId(String userId) async {
    try {
      List<User> friendsSuggestionList =
          await FriendRepository.getUserFriendsSuggestionsByUserId(userId);
      emit(GetFriendSuggestionSuccess(
          friendSuggestionList: friendsSuggestionList));
    } catch (e) {
      emit(Failure(exception: e));
    }
  }
}
