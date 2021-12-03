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

class CoachRecommendationsDefaultValue extends CoachRecommendationsState {
  CoachRecommendationsDefaultValue({this.coachRecommendationListDefaultValue});
  final List<CoachRecommendationDefault> coachRecommendationListDefaultValue;
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
    if (subscription != null) {
      subscription.cancel();
      subscription = null;
      emitCoachRecommendationDefaultValue();
    }
  }

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>> getStream(String userId, String coachId) {
    subscription ??= _coachRepository.getRecommendationSubscription(userId, coachId).listen((snapshot) async {
      List<Recommendation> _recommendations = [];
      List<Recommendation> _recommendationsUpdated = [];
      List<Recommendation> _recommendationsUpdatedContent = [];

      if (snapshot.docChanges.isNotEmpty) {
        snapshot.docChanges.forEach((doc) {
          final Map<String, dynamic> content = doc.doc.data();
          _recommendationsUpdated.add(Recommendation.fromJson(content));
        });
      }
      if (snapshot.docs.isNotEmpty) {
        snapshot.docs.forEach((doc) {
          final Map<String, dynamic> content = doc.data();
          _recommendations.add(Recommendation.fromJson(content));
        });
      }

      if (_recommendationsUpdated.length >= _recommendations.length) {
        _recommendationsUpdated.forEach((updatedItem) {
          _recommendations.forEach((recommendationItem) {
            updatedItem.id == recommendationItem.id
                ? updatedItem != recommendationItem
                    ? _recommendationsUpdatedContent.add(updatedItem)
                    : null
                : null;
          });
        });
      } else {
        _recommendationsUpdatedContent.addAll(_recommendationsUpdated);
      }

      _recommendationsUpdatedContent.isNotEmpty
          ? emit(CoachRecommendationsUpdate(
              coachRecommendationContent: await getCoachRecommendationsData(coachRecommendationContent: _recommendationsUpdatedContent)))
          : emit(CoachRecommendationsSuccess(
              coachRecommendationList: await getCoachRecommendationsData(coachRecommendationContent: _recommendations)));
    });
    return subscription;
  }

  void getCoachRecommendations(String userId, String coachId) async {
    try {
      emit(LoadingCoachRecommendations());
      final List<Recommendation> coachRecommendations = await _coachRepository.getCoachRecommendationsForUser(userId, coachId);
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

  Future<List<CoachRecommendationDefault>> getCoachRecommendationsData({List<Recommendation> coachRecommendationContent}) async {
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

  void setRecommendationNotificationAsViewed(String recommendationId, String coachId, String userId, bool notificationValue) async {
    try {
      await _coachRepository.updateRecommendationNotificationStatus(recommendationId, notificationValue);
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(CoachRecommendationsFailure(exception: exception));
      rethrow;
    }
  }

  void emitCoachRecommendationDefaultValue() async {
    try {
      emit(CoachRecommendationsDefaultValue(coachRecommendationListDefaultValue: []));
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
