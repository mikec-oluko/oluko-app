import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/helpers/coach_recommendation_default.dart';
import 'package:oluko_app/models/recommendation.dart';
import 'package:oluko_app/repositories/coach_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class CoachRecommendationsState {}

class LoadingCoachRecommendations extends CoachRecommendationsState {}

class CoachRecommendationsSuccess extends CoachRecommendationsState {
  CoachRecommendationsSuccess({this.coachRecommendationList});
  final List<CoachRecommendationDefault> coachRecommendationList;
}

class CoachRecommendationsUpdate extends CoachRecommendationsState {
  CoachRecommendationsUpdate({this.coachRecommendationContent});
  final List<CoachRecommendationDefault> coachRecommendationContent;
}

class CoachRecommendationsFailure extends CoachRecommendationsState {
  CoachRecommendationsFailure({this.exception});
  final dynamic exception;
}

class CoachRecommendationsBloc extends Cubit<CoachRecommendationsState> {
  final CoachRepository _coachRepository = CoachRepository();
  CoachRecommendationsBloc() : super(LoadingCoachRecommendations());

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>> subscription;
  @override
  void dispose() {
    subscription.cancel();
  }

  void getCoachRecommendations(String userId, String coachId) async {
    try {
      emit(LoadingCoachRecommendations());
      final List<Recommendation> coachRecommendations =
          await _coachRepository.getCoachRecommendationsForUser(userId, coachId);
      List<CoachRecommendationDefault> recommendationsFormatted =
          await getCoachRecommendationsData(coachRecommendationContent: coachRecommendations);
      emit(CoachRecommendationsSuccess(coachRecommendationList: recommendationsFormatted));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(CoachRecommendationsFailure(exception: exception));
      rethrow;
    }
  }

  Future<List<CoachRecommendationDefault>> getCoachRecommendationsData(
      {List<Recommendation> coachRecommendationContent}) async {
    try {
      emit(LoadingCoachRecommendations());
      final List<CoachRecommendationDefault> coachRecommendations =
          await _coachRepository.getRecommendationsInfo(coachRecommendationContent);
      return coachRecommendations;
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(CoachRecommendationsFailure(exception: exception));
      rethrow;
    }
  }

  void setRecommendationNotificationAsViewed(
      String recommendationId, String coachId, String userId, bool notificationValue) async {
    try {
      await _coachRepository.updateRecommendationNotificationStatus(recommendationId, notificationValue);
      getCoachRecommendations(userId, coachId);
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(CoachRecommendationsFailure(exception: exception));
      rethrow;
    }
  }
}
