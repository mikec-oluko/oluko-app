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

class GetQuantityOfMessagesAfterLast extends ChatSliderState {
  final List<int> messageQuantityList;
  GetQuantityOfMessagesAfterLast(this.messageQuantityList);
}

class GetChatSliderUpdate extends ChatSliderState {
  final List<Course> courses;
  GetChatSliderUpdate({this.courses});
}

class ChatSliderBloc extends Cubit<ChatSliderState> {
  ChatSliderBloc() : super(ChatSliderLoading());

  Future getCoursesWithChatByUserId(String userId) async {
    try{
    final List<CourseEnrollment> coursesWithChat = await CourseChatRepository.getCoursesWithChatByUserId(userId) as List<CourseEnrollment>;
    emit(ChatSliderByUserSuccess(coursesWithChat));
    } catch (e){
      emit(Failure(e));
    }

  }

  void getMessagesAfterLast(String userId, List<CourseEnrollment> courses) async {
    try {
      final List<int> msgQuantityList = [];
      for (final course in courses) {
        final CourseChat chat = await CourseChatRepository.getCourseChatById(course.course.id);
        final lastMessageList = chat.lastMessageSeenUsers;
        if (lastMessageList == null) {
          msgQuantityList.add(0);
        } else {
          UserMessageSubmodel lastMessage;
          for (final item in lastMessageList) {
            if (item.user.id == userId) {
              lastMessage = item;
              break;
            }
          }
          final List<Message> messagesAfterLastView = await CourseChatRepository.getMessagesAfterMessageId(course.course.id, lastMessage?.messageId);
          msgQuantityList.add(messagesAfterLastView.length);
        }
      }
      emit(GetQuantityOfMessagesAfterLast(msgQuantityList));
    } catch (e) {
      emit(Failure(e));
    }
  }
}
