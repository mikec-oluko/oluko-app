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

abstract class ChatSliderState {}

class ChatSliderLoading extends ChatSliderState {}

class Failure extends ChatSliderState {
  final dynamic exception;
  Failure(this.exception);
}

class ChatSliderByUserSuccess extends ChatSliderState {
  final List<CourseEnrollment> courses;
  ChatSliderByUserSuccess(this.courses);
}

// class GetQuantityOfMessagesAfterLast extends ChatSliderState {
//   final Map<String, int> coursesNotificationQuantity;
//   GetQuantityOfMessagesAfterLast(this.coursesNotificationQuantity);
// }

// class GetChatSliderUpdate extends ChatSliderState {
//   final List<Course> courses;
//   GetChatSliderUpdate({this.courses});
// }

class MessagesNotificationUpdated extends ChatSliderState {
  final String courseId;
  final int quantity;
  MessagesNotificationUpdated({this.courseId, this.quantity});
}

class ChatSliderBloc extends Cubit<ChatSliderState> {
  ChatSliderBloc() : super(ChatSliderLoading());

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

  Future getCoursesWithChatByUserId(String userId) async {
    try {
      final List<CourseEnrollment> coursesWithChat = await CourseChatRepository.getCoursesWithChatByUserId(userId) as List<CourseEnrollment>;
      emit(ChatSliderByUserSuccess(coursesWithChat));
    } catch (e) {
      emit(Failure(e));
    }
  }

  // void getMessagesAfterLast(String userId, List<CourseEnrollment> courseEnrollments) async {
  //   try {

  //     Map<String, int> coursesNotificationQuantity = {};

  //     for (final enrollment in courseEnrollments) {
  //       final courseChatRepository = CourseChatRepository();
  //       final CourseChat chat = await courseChatRepository.getCourseChatById(enrollment.course.id);
  //       UserMessageSubmodel lastMessage = chat.lastMessageSeenUsers.firstWhere((chat) => chat.user.id == userId, orElse: () => null);
  //       final List<Message> messagesAfterLastView =
  //           await courseChatRepository.getMessagesBeforeMessageId(enrollment.course.id, lastMessage?.messageId, limit: 99);
  //       coursesNotificationQuantity[enrollment.course.id] = messagesAfterLastView.length;
  //     }
  //     emit(GetQuantityOfMessagesAfterLast(coursesNotificationQuantity));
  //   } catch (e) {
  //     emit(Failure(e));
  //   }
  // }

Future<void> listenToMessages(List<CourseEnrollment> courseChatIds, String userId) async {
  try {
    final courseChatRepository = CourseChatRepository();

    for (final courseChat in courseChatIds) {
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
