import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/message.dart';
import 'package:oluko_app/repositories/chat_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class MessageState {}

class MessageLoading extends MessageState {}

class MessageSuccess extends MessageState {
  List<Message> messages;
  MessageSuccess({this.messages});
}

class MessageFailure extends MessageState {
  final dynamic exception;

  MessageFailure({this.exception});
}

class MessageBloc extends Cubit<MessageState> {
  MessageBloc() : super(MessageLoading());

  void get(BuildContext context, String userId, String targetUserId) async {
    try {
      //Get chat and message info from Chat repository
      List<Message> messages =
          await ChatRepository().getMessages(userId, targetUserId);
      emit(MessageSuccess(messages: messages));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(MessageFailure(exception: exception));
      rethrow;
    }
  }
}
