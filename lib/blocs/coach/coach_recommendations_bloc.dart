import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/helpers/coach_recommendation_default.dart';
import 'package:oluko_app/models/recommendation.dart';
import 'package:oluko_app/repositories/coach_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class CoachRecommendationsState {}

class LoadingCoachRecommendations extends CoachRecommendationsState {}

class CoachRecommendationsSuccess extends CoachRecommendationsState {
  CoachRecommendationsSuccess({this.coachRecommendationList});
  final List<Recommendation> coachRecommendationList;
}

class CoachRecommendationsData extends CoachRecommendationsState {
  CoachRecommendationsData({this.coachRecommendationContent});
  final List<CoachRecommendationDefault> coachRecommendationContent;
}

class CoachRecommendationsFailure extends CoachRecommendationsState {
  CoachRecommendationsFailure({this.exception});
  final dynamic exception;
}

class CoachRecommendationsBloc extends Cubit<CoachRecommendationsState> {
  final CoachRepository _coachRepository = CoachRepository();
  CoachRecommendationsBloc() : super(LoadingCoachRecommendations());

  void getCoachRecommendations(String userId, String coachId) async {
    try {
      emit(LoadingCoachRecommendations());
      final List<Recommendation> coachRecommendations =
          await _coachRepository.getCoachRecommendationsForUser(userId, coachId);
      emit(CoachRecommendationsSuccess(coachRecommendationList: coachRecommendations));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(CoachRecommendationsFailure(exception: exception));
      rethrow;
    }
  }

  void getCoachRecommendationsData({List<Recommendation> coachRecommendationContent}) async {
    try {
      emit(LoadingCoachRecommendations());
      final List<CoachRecommendationDefault> coachRecommendations =
          await _coachRepository.getRecommendationsInfo(coachRecommendationContent);

      emit(CoachRecommendationsData(coachRecommendationContent: coachRecommendations));
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
