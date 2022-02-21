import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/chat.dart';
import 'package:oluko_app/models/message.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/repositories/chat_repository.dart';
import 'package:oluko_app/repositories/user_repository.dart';
import 'package:oluko_app/utils/app_messages.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class HiFiveState {}

class HiFiveLoading extends HiFiveState {}

class HiFiveSuccess extends HiFiveState {
  Map<Chat, List<Message>> chat;
  List<UserResponse> users;
  String alertMessage;
  HiFiveSuccess({this.chat, this.users, this.alertMessage});
}

class HiFiveFailure extends HiFiveState {
  final dynamic exception;

  HiFiveFailure({this.exception});
}

class HiFiveBloc extends Cubit<HiFiveState> {
  HiFiveBloc() : super(HiFiveLoading());

  HiFiveSuccess _lastState;
  void get(String userId) async {
    try {
      //Get chat and message info from Chat repository
      final Map<Chat, List<Message>> chatsWithMessages = await ChatRepository().getChatsWithMessages(userId);

      //Filter messages that are not HiFives
      chatsWithMessages.updateAll((Chat chat, List<Message> messages) {
        messages.removeWhere(
          (message) => message.message != message.hifiveMessageCode,
        );
        return messages;
      });

      //Remove Chats with no HiFives
      chatsWithMessages.removeWhere(
        (Chat chat, List<Message> messages) => messages == null || messages.isEmpty,
      );

      //Remove HiFives sended by me
      chatsWithMessages.removeWhere((Chat chat, List<Message> messages) => messages.last.createdBy == userId);

      //Get Users from Chats
      final List<UserResponse> userList = await Future.wait(
        chatsWithMessages.keys.map((Chat chat) {
          return UserRepository().getById(chat.id);
        }),
      );
      _lastState = HiFiveSuccess(chat: chatsWithMessages, users: userList);
      emit(_lastState);
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(HiFiveFailure(exception: exception));
      rethrow;
    }
  }

  void sendHiFive(BuildContext context, String userId, String targetUserId) async {
    ChatRepository.removeNotification(userId, targetUserId);
    Message hiFiveMessage = await ChatRepository().sendHiFive(userId, targetUserId);
    if (_lastState != null && _chatExists(_lastState, targetUserId)) {
      _lastState.chat.removeWhere((key, value) => key.id == targetUserId);
      _lastState.users.removeWhere((element) => element.id == targetUserId);
      emit(HiFiveSuccess(chat: _lastState.chat, users: _lastState.users, alertMessage: OlukoLocalizations.get(context, 'hiFiveSent')));
    } else {
      get(userId);
    }
  }

  void sendHiFiveToAll(BuildContext context, String userId, List<String> targetUserIds) async {
    List<Message> results = await Future.wait(targetUserIds.map((String targetUserId) {
      ChatRepository.removeNotification(userId, targetUserId);
      return ChatRepository().sendHiFive(userId, targetUserId);
    }));

    _lastState.users.removeWhere((element) => targetUserIds.contains(element.id));
    _lastState.chat.removeWhere((key, value) => targetUserIds.contains(key.id));
    emit(HiFiveSuccess(
        chat: _lastState.chat,
        users: _lastState.users,
        alertMessage: '${targetUserIds.length} Hi-Five${targetUserIds.length > 1 ? 's' : ''} sended'));
  }

  void ignoreHiFive(BuildContext context, String userId, String targetUserId) async {
    ChatRepository.removeNotification(userId, targetUserId);
    ChatRepository.removeAllHiFives(userId, targetUserId);
    if (_lastState != null && _chatExists(_lastState, targetUserId)) {
      _lastState.chat.removeWhere((key, value) => key.id == targetUserId);
      _lastState.users.removeWhere((element) => element.id == targetUserId);
      emit(HiFiveSuccess(chat: _lastState.chat, users: _lastState.users, alertMessage: OlukoLocalizations.get(context, 'hiFiveRemoved')));
    } else {
      get(userId);
    }
  }

  bool _chatExists(HiFiveSuccess lastState, String targetUserId) {
    return lastState.chat.keys.where((element) => element.id == targetUserId).toList().isNotEmpty;
  }
}
