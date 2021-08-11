import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/friend.dart';
import 'package:oluko_app/models/friend_model.dart';
import 'package:oluko_app/models/friend_request_model.dart';
import 'package:oluko_app/repositories/friend_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class ConfirmFriendState {}

class Loading extends ConfirmFriendState {}

class ConfirmFriendSuccess extends ConfirmFriendState {
  FriendModel friendModel;
  ConfirmFriendSuccess({this.friendModel});
}

class ConfirmFriendFailure extends ConfirmFriendState {
  final Exception exception;

  ConfirmFriendFailure({this.exception});
}

class FriendBloc extends Cubit<ConfirmFriendState> {
  FriendBloc() : super(Loading());

  void confirmFriend(Friend friend, FriendRequestModel friendRequest) async {
    try {
      FriendModel friendModel =
          await FriendRepository.confirmFriendRequest(friend, friendRequest);
      emit(ConfirmFriendSuccess(friendModel: friendModel));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(ConfirmFriendFailure(exception: exception));
    }
  }
}
