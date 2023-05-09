import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/course_chat.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/message.dart';
import 'package:oluko_app/models/submodels/user_message_submodel.dart';
import 'package:oluko_app/repositories/course_chat_repository.dart';
import 'package:oluko_app/repositories/course_enrollment_repository.dart';

abstract class ChatSliderMessagesState {}

class ChatSliderMessagesLoading extends ChatSliderMessagesState {}

class Failure extends ChatSliderMessagesState {
  final dynamic exception;
  Failure(this.exception);
}

class MessagesNotificationUpdated extends ChatSliderMessagesState {
  final String courseId;
  final int quantity;
  MessagesNotificationUpdated({this.courseId, this.quantity});
}

class ChatSliderMessagesBloc extends Cubit<ChatSliderMessagesState> {
  ChatSliderMessagesBloc() : super(ChatSliderMessagesLoading());

  List<StreamSubscription> _messagesSubscription;

  @override
  void dispose() {
    if (_messagesSubscription != null) {
      for (final element in _messagesSubscription) {
        element.cancel();
      }
      _messagesSubscription = [];
    }
  }

Future<void> listenToMessages(String userId, {List<CourseEnrollment> enrollments}) async {
  try {
    if(enrollments.isEmpty){
      enrollments = await CourseChatRepository.getCoursesWithChatByUserId(userId) as List<CourseEnrollment>;
    }
    final courseChatRepository = CourseChatRepository();

    for (final courseChat in enrollments) {
      final String courseChatId = courseChat.course.id;
      final CourseChat chat = await courseChatRepository.getCourseChatById(courseChatId);
      final UserMessageSubmodel lastMessage = chat.lastMessageSeenUsers.firstWhere((chat) => chat.user.id == userId,orElse: () => null,);

      final messageReferenceSnapshot = await CourseChatRepository().getMessageByMessageIdAndChatId(courseChatId, lastMessage?.messageId);

      final StreamSubscription messagesSubscription = CourseChatRepository().listenToMessagesByCourseChatId(courseChatId, limit: 99, message: messageReferenceSnapshot,)
      .listen(
        (snapshot) async {
          final List<Message> messages = snapshot.docs.map((doc) => Message.fromJson(doc.data())).toList();
          emit(MessagesNotificationUpdated(courseId: courseChatId, quantity: messages.length));
        },
      );
      _messagesSubscription ??= [];
      _messagesSubscription.add(messagesSubscription);
    }
  } catch (e) {
    emit(Failure(e));
  }
}
}
