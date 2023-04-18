import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_bloc.dart';
import 'package:oluko_app/models/course_chat.dart';
import 'package:oluko_app/models/submodels/object_submodel.dart';
import 'package:oluko_app/models/submodels/user_message_submodel.dart';
import 'package:oluko_app/repositories/course_chat_repository.dart';

abstract class CourseEnrollmentChatState {}

class CourseEnrollmentLoading extends CourseEnrollmentChatState {}

class Failure extends CourseEnrollmentChatState {
  final dynamic exception;
  Failure({this.exception});
}

class CourseEnrollmentChatBloc extends Cubit<CourseEnrollmentChatState> {
  CourseEnrollmentChatBloc() : super(CourseEnrollmentLoading());

  void create() async{
    ObjectSubmodel course = ObjectSubmodel(id: '1223', name: 'weqweqw', reference: null, image: null);
    List<UserMessageSubmodel> lastMessageSeenUsers = [];
    CourseChat newCourse = CourseChat(course: course, lastMessageSeenUsers: lastMessageSeenUsers);
    CourseChat courseEnrollment = await CourseChatRepository.create(newCourse);
      emit(CourseEnrollmentLoading());
    // try{

    // }catch(exception, stackTrace){

    // }
  }
}
