import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_bloc.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/course_chat.dart';
import 'package:oluko_app/models/message.dart';
import 'package:oluko_app/models/submodels/object_submodel.dart';
import 'package:oluko_app/models/submodels/user_message_submodel.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/repositories/auth_repository.dart';
import 'package:oluko_app/repositories/course_chat_repository.dart';
import 'package:oluko_app/repositories/course_repository.dart';
import 'package:oluko_app/repositories/user_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class CourseEnrollmentChatState {}

class CourseEnrollmentLoading extends CourseEnrollmentChatState {}

class ChatMessageAdded extends CourseEnrollmentChatState {
  final String userId;
  final String courseId;
  final String userMessage;

  ChatMessageAdded(this.userId, this.courseId, this.userMessage);
}

class CourseEnrollmentChatSuccess extends CourseEnrollmentChatState {
}

class MessagesUpdated extends CourseEnrollmentChatState {
  final List<Message> messages;
  final DocumentSnapshot lastDocument;
  MessagesUpdated(this.messages, {this.lastDocument});
}

class MessagesDispose extends CourseEnrollmentChatState {
  MessagesDispose();
}

class MessagesScroll extends CourseEnrollmentChatState {
  final List<Message> messages;
  MessagesScroll(this.messages);
}
class Failure extends CourseEnrollmentChatState {
  final dynamic exception;
  Failure({this.exception});
}

class CourseEnrollmentChatBloc extends Cubit<CourseEnrollmentChatState> {
  CourseEnrollmentChatBloc() : super(CourseEnrollmentLoading());

  StreamSubscription _messagesSubscription;

  @override
  void dispose() {
    if (_messagesSubscription != null) {
      _messagesSubscription.cancel();
      _messagesSubscription = null;
      emitChatDispose();
    }
  }

  Future<void> createMessage(String userId, String courseId, String userMessage) async {
    try {
      final repository = UserRepository();
      final DocumentReference<Object> userReference = repository.getUserReference(userId);
      final UserResponse user = await repository.getById(userId);
      final Course course = await CourseRepository.get(courseId);

      final userObj = {
        'id': userId, 
        'image': user.avatar, 
        'name': '${user.firstName} ${user.lastName}', 
        'reference': userReference
        };

      final messageJSON = {
        'message': userMessage, 
        'seenAt': '', 
        'user': userObj
      };

      Message message = Message.fromJson(messageJSON);
      message.createdAt = Timestamp.now();
      await CourseChatRepository.createMessage(message, course.id);

    } catch (e) {
      emit(Failure());
    }
  }

  void listenToMessages(String courseChatId) {
    _messagesSubscription = CourseChatRepository.listenToMessagesByCourseChatId(courseChatId).listen((snapshot) {
      final messages = snapshot.docs.map((doc) => Message.fromJson(doc.data())).toList().reversed.toList();
      saveLastMessageUserSaw(courseChatId, messages[messages.length - 1]);
      emit(MessagesUpdated(messages));
    });
  }

  Future<void> saveLastMessageUserSaw(String courseChatId, Message message) async {
    try {
      final repository = UserRepository();
      final DocumentReference<Object> messageReference = CourseChatRepository.getMessageReference(courseChatId, message.id);
      final User user = AuthRepository.getLoggedUser();
      final DocumentReference<Object> userReference = repository.getUserReference(user.uid);

      final userJSON = {
        'id': user.uid, 
        'image': null, 
        'name': user.displayName, 
        'reference': userReference
      };
      final userMessageJSON = {
        'message_reference': messageReference, 
        'message_id': message.id, 
        'user': userJSON
        };
      final UserMessageSubmodel userMessage = UserMessageSubmodel.fromJson(userMessageJSON);
      await CourseChatRepository.updateUsersLastSeenMessage(courseChatId, userMessage);

    } catch (e) {
      emit(Failure());
    }
  }

  Future<void> getMessagesAfterMessage(Message message, String courseChatId) async {
    try{
      List<Message> messages = await CourseChatRepository.getMessagesAfterMessageId(courseChatId, message.id, limit: 10);
      emit(MessagesScroll(messages.reversed.toList()));
    }catch(exception, stackTrace){
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      print(exception);
       emit(Failure());
    }
    
  }

  void emitChatDispose() async {
    try {
      emit(MessagesDispose());
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(Failure(exception: exception));
      rethrow;
    }
  }
}
