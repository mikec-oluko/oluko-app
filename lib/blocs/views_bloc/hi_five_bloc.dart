import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/chat.dart';
import 'package:oluko_app/models/message.dart';
import 'package:oluko_app/repositories/chat_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class HiFiveState {}

class HiFiveLoading extends HiFiveState {}

class HiFiveSuccess extends HiFiveState {
  List<Chat> chat;
  HiFiveSuccess({this.chat});
}

class HiFiveFailure extends HiFiveState {
  final dynamic exception;

  HiFiveFailure({this.exception});
}

class HiFiveBloc extends Cubit<HiFiveState> {
  HiFiveBloc() : super(HiFiveLoading());

  void get(BuildContext context, String userId) async {
    try {
      //Get chat and message info from Chat repository
      final Map<Chat, List<Message>> chatsWithMessages =
          await ChatRepository().getChatsWithMessages(userId);

      emit(HiFiveSuccess(chat: null));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(HiFiveFailure(exception: exception));
      rethrow;
    }
  }
}
