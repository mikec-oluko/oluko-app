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
import 'package:oluko_app/models/recommendation.dart';
import 'package:oluko_app/models/submodels/friend_request_model.dart';
import 'package:oluko_app/models/submodels/user_message_submodel.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/repositories/coach_repository.dart';
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
  CoachTabNotification({this.annotationsNotViewed, this.recommendationsNotViewed});
}

class Failure extends CoachTabNotificationState {
  final dynamic exception;
  Failure({this.exception});
}

class CoachTabNotificationBloc extends Cubit<CoachTabNotificationState> {
  CoachTabNotificationBloc() : super(CoachTabNotificationLoading());

  StreamSubscription _annotationsSubscription;
  StreamSubscription _recommendationSubscription;
  List<Annotation> userAnnotations = [];
  List<Recommendation> userRecommendations = [];


   Future<void> listenAnnotationsByUserId({String userId}) async {
    try {
       CoachRepository coachRepository = CoachRepository();
      userId ??= AuthRepository.getLoggedUser().uid;
      CoachAssignment coachAssignment = await coachRepository.getCoachAssignmentByUserId(userId);
      _annotationsSubscription = coachRepository.getAnnotationSubscription(userId, coachAssignment.coachId).listen((snapshot) async {
          final List<Annotation> annotations = snapshot.docs.map((e) => Annotation.fromJson(e.data())).toList();
          if(annotations == null || annotations.isEmpty) {
            userAnnotations = [];
            emit(CoachTabNotification(annotationsNotViewed: userAnnotations, recommendationsNotViewed: userRecommendations));

          }else{
            final List<Annotation> annotationsNotViewed = annotations.where((element) => !element.notificationViewed).toList();
            userAnnotations = annotationsNotViewed;
            emit(CoachTabNotification(annotationsNotViewed: userAnnotations, recommendationsNotViewed: userRecommendations));
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
            emit(CoachTabNotification(recommendationsNotViewed: userRecommendations, annotationsNotViewed: userAnnotations));

          }else{
            final List<Recommendation> recommendationNotViewed = recommendations.where((element) => !element.notificationViewed).toList();
            userRecommendations = recommendationNotViewed;
            emit(CoachTabNotification(recommendationsNotViewed: userRecommendations, annotationsNotViewed: userAnnotations));
          }
      });
      
    } catch (e) {
      emit(Failure(exception: e));
    }
  }
}