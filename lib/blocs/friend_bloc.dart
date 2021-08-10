import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/friend.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/repositories/friend_repository.dart';
import 'package:oluko_app/repositories/user_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class FriendState {}

class Loading extends FriendState {}

class GetFriendsSuccess extends FriendState {
  List<UserResponse> friendUsers;
  GetFriendsSuccess({this.friendUsers});
}

class GetFriendRequestsSuccess extends FriendState {
  List<UserResponse> friendRequestList;
  GetFriendRequestsSuccess({this.friendRequestList});
}

class GetFriendSuggestionSuccess extends FriendState {
  List<UserResponse> friendSuggestionList;
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
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(Failure(exception: exception));
    }
  }

  void getUserFriendsRequestByUserId(String userId) async {
    try {
      Friend friendInformation =
          await FriendRepository.getUserFriendsRequestByUserId(userId);

      List<UserResponse> friendRequestUsers = await Future.wait(
          friendInformation.friendRequestReceived
              .map((e) => UserRepository().getById(e.id))
              .toList());

      emit(GetFriendRequestsSuccess(friendRequestList: friendRequestUsers));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(Failure(exception: exception));
    }
  }

  void getUserFriendsSuggestionsByUserId(String userId) async {
    try {
      List<User> friendsSuggestionList =
          await FriendRepository.getUserFriendsSuggestionsByUserId(userId);
      emit(GetFriendSuggestionSuccess(friendSuggestionList: null));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(Failure(exception: exception));
    }
  }
}
