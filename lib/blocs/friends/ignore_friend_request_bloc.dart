import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/friend.dart';
import 'package:oluko_app/models/submodels/friend_model.dart';
import 'package:oluko_app/models/submodels/friend_request_model.dart';
import 'package:oluko_app/repositories/friend_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class IgnoreFriendRequestState {}

class IgnoreFriendRequestLoading extends IgnoreFriendRequestState {}

class IgnoreFriendRequestSuccess extends IgnoreFriendRequestState {
  FriendRequestModel friendRequestModel;
  IgnoreFriendRequestSuccess({this.friendRequestModel});
}

class IgnoreFriendRequestFailure extends IgnoreFriendRequestState {
  final Exception exception;

  IgnoreFriendRequestFailure({this.exception});
}

class IgnoreFriendRequestBloc extends Cubit<IgnoreFriendRequestState> {
  IgnoreFriendRequestBloc() : super(IgnoreFriendRequestLoading());

  void ignoreFriend(BuildContext context, Friend friend,
      FriendRequestModel friendRequest) async {
    try {
      FriendRequestModel friendRequestModel =
          await FriendRepository.ignoreFriendRequest(friend, friendRequest);
      emit(IgnoreFriendRequestSuccess(friendRequestModel: friendRequestModel));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(IgnoreFriendRequestFailure(exception: exception));
    }
  }
}
