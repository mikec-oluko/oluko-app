import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/annotation.dart';
import 'package:oluko_app/models/coach_assignment.dart';
import 'package:oluko_app/models/course_chat.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/friend.dart';
import 'package:oluko_app/models/message.dart';
import 'package:oluko_app/models/submodels/friend_request_model.dart';
import 'package:oluko_app/models/submodels/user_message_submodel.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/repositories/coach_repository.dart';
import 'package:oluko_app/repositories/course_chat_repository.dart';
import 'package:oluko_app/repositories/friend_repository.dart';
import 'package:oluko_app/repositories/auth_repository.dart';

abstract class CoachTabNotificationState {
}

class CoachTabNotificationLoading extends CoachTabNotificationState {}

class CoachTabNotification extends CoachTabNotificationState {
  List<Annotation> annotationsNotViewed;
  CoachTabNotification({this.annotationsNotViewed});
}

class Failure extends CoachTabNotificationState {
  final dynamic exception;
  Failure({this.exception});
}

class CoachTabNotificationBloc extends Cubit<CoachTabNotificationState> {
  CoachTabNotificationBloc() : super(CoachTabNotificationLoading());

  StreamSubscription _annotationsSubscription;

   Future<void> listenAnnotationsByUserId({String userId}) async {
    try {
       CoachRepository coachRepository = CoachRepository();
      userId ??= AuthRepository.getLoggedUser().uid;
      CoachAssignment coachAssignment = await coachRepository.getCoachAssignmentByUserId(userId);
      _annotationsSubscription = coachRepository.getAnnotationSubscription(userId, coachAssignment.coachId).listen((snapshot) async {
          final List<Annotation> annotations = snapshot.docs.map((e) => Annotation.fromJson(e.data())).toList();
          if(annotations == null || annotations.isEmpty) {
            emit(CoachTabNotification(annotationsNotViewed: []));

          }else{
            final List<Annotation> annotationsNotViewed = annotations.where((element) => !element.notificationViewed).toList();
            emit(CoachTabNotification(annotationsNotViewed: annotationsNotViewed));
          }
      });
      
    } catch (e) {
      emit(Failure(exception: e));
    }
  }
}