import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/chat.dart';
import 'package:oluko_app/models/message.dart';
import 'package:oluko_app/repositories/chat_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class ChatState {}

class IgnoreFriendRequestLoading extends ChatState {}

class ChatSuccess extends ChatState {
  List<Chat> chat;
  ChatSuccess({this.chat});
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
      final List<Chat> chat = await ChatRepository().getByUserId(userId);

      emit(ChatSuccess(chat: chat));
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
