import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_bloc.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/course_chat.dart';
import 'package:oluko_app/models/message.dart';
import 'package:oluko_app/models/submodels/object_submodel.dart';
import 'package:oluko_app/models/submodels/user_message_submodel.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/repositories/course_chat_repository.dart';
import 'package:oluko_app/repositories/course_repository.dart';
import 'package:oluko_app/repositories/user_repository.dart';

abstract class CourseEnrollmentChatState {}

class CourseEnrollmentLoading extends CourseEnrollmentChatState {}
class ChatMessageAdded extends CourseEnrollmentChatState {
  final String userId;
  final String courseId;
  final String userMessage;

  ChatMessageAdded(this.userId, this.courseId, this.userMessage);
}

class MessagesUpdated extends CourseEnrollmentChatState {
  final List<Message> messages;
  MessagesUpdated(this.messages);
}

class Failure extends CourseEnrollmentChatState {
  final dynamic exception;
  Failure({this.exception});
}

class CourseEnrollmentChatBloc extends Cubit<CourseEnrollmentChatState> {
  CourseEnrollmentChatBloc() : super(CourseEnrollmentLoading());

  void createMessage(String userId, String courseId, String userMessage) async {   
    try {
      final repository = UserRepository();
      final DocumentReference<Object> userReference = repository.getUserReference(userId);
      final UserResponse user = await repository.getById(userId);
      final Course course = await CourseRepository.get(courseId);
      
      final userObj = {
        'id': userId,
        'image':  user.avatar,
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
    CourseChatRepository.getAllMessagesByCourseChatId(courseChatId).listen((snapshot) {
        final messages = snapshot.docs.map((doc) => Message.fromJson(doc.data())).toList();
        emit(MessagesUpdated(messages));
    });
  }

  void saveLastMessageUserSaw(String courseChatId, Message message) async{
    try {
      // final messageJSON ={
      //   'id': ,
      //   'image':  ,
      //   'name': ',
      //   'reference': 
      // };

      // final userMessageJSON = {
      //   'message': message.message,
      //   'user': message.user
      // };

      // final UserMessageSubmodel userMessage = 

      // await CourseChatRepository.updateUsersLastSeenMessage(courseChatId);

    } catch (e) {
      emit(Failure());
    }
  }
}
