import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/friend.dart';
import 'package:oluko_app/models/submodels/friend_model.dart';
import 'package:oluko_app/models/submodels/friend_request_model.dart';
import 'package:oluko_app/repositories/friend_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class ChatState {}

class IgnoreFriendRequestLoading extends ChatState {}

class ChatSuccess extends ChatState {
  FriendRequestModel friendRequestModel;
  ChatSuccess({this.friendRequestModel});
}

class ChatFailure extends ChatState {
  final dynamic exception;

  ChatFailure({this.exception});
}

class ChatBloc extends Cubit<ChatState> {
  ChatBloc() : super(IgnoreFriendRequestLoading());

  void get(BuildContext context, String userId) async {
    try {
      //Get chat and message info from Chat repository
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(ChatFailure(exception: exception));
      rethrow;
    }
  }
}
