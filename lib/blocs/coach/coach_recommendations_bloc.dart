import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/coach_timeline_item.dart';
import 'package:oluko_app/models/recommendation.dart';
import 'package:oluko_app/repositories/coach_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class CoachRecommendationsState {}

class LoadingCoachRecommendations extends CoachRecommendationsState {}

class CoachRecommendationsSuccess extends CoachRecommendationsState {
  CoachRecommendationsSuccess({this.coachRecommendationList});
  final List<Recommendation> coachRecommendationList;
}

class CoachRecommendationsAsTimelineItem extends CoachRecommendationsState {
  CoachRecommendationsAsTimelineItem({this.coachRecommendationTimelineContent});
  final List<CoachTimelineItem> coachRecommendationTimelineContent;
}

class CoachRecommendationsFailure extends CoachRecommendationsState {
  CoachRecommendationsFailure({this.exception});
  final dynamic exception;
}

class CoachRecommendationsBloc extends Cubit<CoachRecommendationsState> {
  CoachRecommendationsBloc() : super(LoadingCoachRecommendations());

  void getCoachRecommendations(String userId, String coachId) async {
    try {
      emit(LoadingCoachRecommendations());
      final List<Recommendation> coachRecommendations =
          await CoachRepository().getCoachRecommendationsForUser(userId, coachId);
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

  void getCoachRecommendationsAsTimelineItems({List<Recommendation> coachRecommendationContent}) async {
    try {
      emit(LoadingCoachRecommendations());
      final List<CoachTimelineItem> coachRecommendations = await CoachRepository().getRecommendationsInfo(coachRecommendationContent);

      emit(CoachRecommendationsAsTimelineItem(coachRecommendationTimelineContent: coachRecommendations));
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
