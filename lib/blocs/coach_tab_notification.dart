import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/annotation.dart';
import 'package:oluko_app/models/coach_assignment.dart';
import 'package:oluko_app/models/coach_media_message.dart';
import 'package:oluko_app/models/course_chat.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/friend.dart';
import 'package:oluko_app/models/message.dart';
import 'package:oluko_app/models/recommendation.dart';
import 'package:oluko_app/models/submodels/friend_request_model.dart';
import 'package:oluko_app/models/submodels/user_message_submodel.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/repositories/coach_repository.dart';
import 'package:oluko_app/repositories/coach_video_message_repository.dart';
import 'package:oluko_app/repositories/course_chat_repository.dart';
import 'package:oluko_app/repositories/friend_repository.dart';
import 'package:oluko_app/repositories/auth_repository.dart';
import 'package:oluko_app/repositories/recommendation_repository.dart';

abstract class CoachTabNotificationState {
}

class CoachTabNotificationLoading extends CoachTabNotificationState {}

class CoachTabNotification extends CoachTabNotificationState {
  List<Annotation> annotationsNotViewed;
  List<Recommendation> recommendationsNotViewed;
  List<CoachMediaMessage> coachVideoMessagesNotViewed;
  bool welcomeVideoNotSeen;
  CoachTabNotification({this.annotationsNotViewed, this.recommendationsNotViewed, this.welcomeVideoNotSeen, this.coachVideoMessagesNotViewed});
}

class Failure extends CoachTabNotificationState {
  final dynamic exception;
  Failure({this.exception});
}

class CoachTabNotificationBloc extends Cubit<CoachTabNotificationState> {
  CoachTabNotificationBloc() : super(CoachTabNotificationLoading());

  StreamSubscription _annotationsSubscription;
  StreamSubscription _recommendationSubscription;
  StreamSubscription _coachSubscription;
  StreamSubscription _videoMessagesSubscription;


  List<Annotation> userAnnotations = [];
  List<Recommendation> userRecommendations = [];
  List<CoachMediaMessage> coachVideoMessages = [];
  bool welcomeVideoNotSeen = false;


   Future<void> listenAnnotationsByUserId({String userId}) async {
    try {
       CoachRepository coachRepository = CoachRepository();
      userId ??= AuthRepository.getLoggedUser().uid;
      CoachAssignment coachAssignment = await coachRepository.getCoachAssignmentByUserId(userId);
      _annotationsSubscription = coachRepository.getAnnotationSubscription(userId, coachAssignment.coachId).listen((snapshot) async {
          final List<Annotation> annotations = snapshot.docs.map((e) => Annotation.fromJson(e.data())).toList();
          if(annotations == null || annotations.isEmpty) {
            userAnnotations = [];
            emit(CoachTabNotification(
              annotationsNotViewed: userAnnotations, 
              recommendationsNotViewed: userRecommendations,
              welcomeVideoNotSeen: welcomeVideoNotSeen,
              coachVideoMessagesNotViewed: coachVideoMessages));

          }else{
            final List<Annotation> annotationsNotViewed = annotations.where((element) => !element.notificationViewed).toList();
            userAnnotations = annotationsNotViewed;
            emit(CoachTabNotification(
              annotationsNotViewed: userAnnotations, 
              recommendationsNotViewed: userRecommendations,
              welcomeVideoNotSeen: welcomeVideoNotSeen,
              coachVideoMessagesNotViewed: coachVideoMessages));
          }
      });
      
    } catch (e) {
      emit(Failure(exception: e));
    }
  }

  Future<void> listenRecommendationsByUserId({String userId}) async{
    try {
      userId ??= AuthRepository.getLoggedUser().uid;
      CoachAssignment coach = await CoachRepository().getCoachAssignmentByUserId(userId);
      _recommendationSubscription = RecommendationRepository().getRecommendationSubscriptionByDestinationUser(userId, coach.coachId).listen((snapshot) async {
          final List<Recommendation> recommendations = snapshot.docs.map((e) => Recommendation.fromJson(e.data())).toList();
          if(recommendations == null || recommendations.isEmpty) {
            userRecommendations = [];
            emit(CoachTabNotification(
              annotationsNotViewed: userAnnotations, 
              recommendationsNotViewed: userRecommendations,
              welcomeVideoNotSeen: welcomeVideoNotSeen,
              coachVideoMessagesNotViewed: coachVideoMessages));

          }else{
            final List<Recommendation> recommendationNotViewed = recommendations.where((element) => !element.notificationViewed).toList();
            userRecommendations = recommendationNotViewed;
            emit(CoachTabNotification(
              annotationsNotViewed: userAnnotations, 
              recommendationsNotViewed: userRecommendations,
              welcomeVideoNotSeen: welcomeVideoNotSeen,
              coachVideoMessagesNotViewed: coachVideoMessages));
          }
      });
      
    } catch (e) {
      emit(Failure(exception: e));
    }
  }

  Future<void> listenWelcomeVideoByUserId({String userId}) async{
    try {
      userId ??= AuthRepository.getLoggedUser().uid;
      _coachSubscription = CoachRepository.getCoachAssignmentByUserIdStream(userId).listen((snapshot) async {
          if(snapshot?.docs?.isEmpty){
            return;
          }
          final CoachAssignment coachAssignment = CoachAssignment.fromJson(snapshot?.docs?.first?.data());
          if(coachAssignment == null || coachAssignment?.coachId == null){
            return;
          }
          welcomeVideoNotSeen = !coachAssignment?.welcomeVideoSeen;
          emit(CoachTabNotification(
            annotationsNotViewed: userAnnotations, 
            recommendationsNotViewed: userRecommendations,
            welcomeVideoNotSeen: welcomeVideoNotSeen,
            coachVideoMessagesNotViewed: coachVideoMessages));
      });
      
    } catch (e) {
      emit(Failure(exception: e));
    }
  }

  Future<void> listenVideoMessagesVideoByUserId({String userId}) async{ //Introductions Videos
    try {
      userId ??= AuthRepository.getLoggedUser().uid;
      CoachAssignment coach = await CoachRepository().getCoachAssignmentByUserId(userId);
      _videoMessagesSubscription = CoachVideoMessageRepository().getStream(userId: userId, coachId: coach.coachId).listen((snapshot) async {
          final List<CoachMediaMessage> videoMessages = snapshot.docs.map((e) => CoachMediaMessage.fromJson(e.data())).toList();
          if(videoMessages == null || videoMessages.isEmpty) {
            coachVideoMessages = [];
            emit(CoachTabNotification(
              annotationsNotViewed: userAnnotations, 
              recommendationsNotViewed: userRecommendations,
              welcomeVideoNotSeen: welcomeVideoNotSeen,
              coachVideoMessagesNotViewed: coachVideoMessages));

          }else{
            final List<CoachMediaMessage> videoMessagesNotViewed = videoMessages.where((element) => !element.viewed).toList();
            coachVideoMessages = videoMessagesNotViewed;
            emit(CoachTabNotification(
              annotationsNotViewed: userAnnotations, 
              recommendationsNotViewed: userRecommendations,
              welcomeVideoNotSeen: welcomeVideoNotSeen,
              coachVideoMessagesNotViewed: coachVideoMessages));
          }
      });
      
    } catch (e) {
      emit(Failure(exception: e));
    }
  }
}