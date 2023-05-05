


import 'package:oluko_app/models/message.dart';
import 'package:oluko_app/models/user_response.dart';

class ChatUtils {
  static List<Message> concatenateMessagesByListenedMessagesAndOldMessages(List<Message> listenedMessages, List<Message> oldMessages) {
    List<Message> newMessages = [];
    if (oldMessages.isEmpty) {
      newMessages = listenedMessages;
    } else {
      final messagesGot = listenedMessages;
      bool messageShown;
      for (final element in messagesGot) {
        {
            messageShown = oldMessages.where((message) => message.id == element.id).isEmpty;
            if (messageShown)
              {
                newMessages = [element, ...oldMessages];
              }
          }
      }
      if(newMessages.isEmpty){
        newMessages = oldMessages;
      }
    }
    return newMessages;
  }
}