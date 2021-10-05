import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/friend.dart';
import 'package:oluko_app/models/submodels/friend_model.dart';
import 'package:oluko_app/repositories/friend_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class FavoriteFriendState {}

class FavoriteFriendLoading extends FavoriteFriendState {}

class FavoriteFriendSuccess extends FavoriteFriendState {
  FriendModel friendModel;
  FavoriteFriendSuccess({this.friendModel});
}

class FavoriteFriendFailure extends FavoriteFriendState {
  final dynamic exception;

  FavoriteFriendFailure({this.exception});
}

class FavoriteFriendBloc extends Cubit<FavoriteFriendState> {
  FavoriteFriendBloc() : super(FavoriteFriendLoading());

  void favoriteFriend(BuildContext context, Friend friend, FriendModel friendModel) async {
    try {
      friendModel.isFavorite = friendModel.isFavorite == null ? true : !friendModel.isFavorite;
      FriendModel updatedFriendModel = await FriendRepository.markFriendAsFavorite(friend, friendModel);
      emit(FavoriteFriendSuccess(friendModel: updatedFriendModel));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(FavoriteFriendFailure(exception: exception));
      rethrow;
    }
  }
}
