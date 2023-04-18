import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/helpers/coach_recommendation_default.dart';
import 'package:oluko_app/models/enums/coach_assignment_status_enum.dart';
import 'package:oluko_app/models/recommendation.dart';
import 'package:oluko_app/repositories/coach_repository.dart';
import 'package:oluko_app/utils/sound_player.dart';
import 'package:oluko_app/utils/sound_utils.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class CoachRecommendationsState {}

class LoadingCoachRecommendations extends CoachRecommendationsState {}

class CoachRecommendationsSuccess extends CoachRecommendationsState {
  CoachRecommendationsSuccess({this.coachRecommendationList});
  final List<CoachRecommendationDefault> coachRecommendationList;
}

class CoachRecommendationsDispose extends CoachRecommendationsState {
  CoachRecommendationsDispose({this.coachRecommendationListDisposeValue});
  final List<CoachRecommendationDefault> coachRecommendationListDisposeValue;
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
  final SoundPlayer _soundPlayer = SoundPlayer();
  CoachRecommendationsBloc() : super(LoadingCoachRecommendations());

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>> subscription;

  @override
  void dispose() {
    if (subscription != null) {
      subscription.cancel();
      subscription = null;
      if (_soundPlayer != null) _soundPlayer?.dispose();
      emitCoachRecommendationDispose();
    }
  }

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>> getStream(String userId, String coachId) {
    return subscription ??= _coachRepository.getRecommendationSubscription(userId, coachId).listen((snapshot) async {
      final Set<Recommendation> _recommendations = {};
      final Set<Recommendation> _recommendationsUpdated = {};
      final Set<Recommendation> _recommendationsUpdatedContent = {};
      try {
        handleDocumentChanges(snapshot, _recommendationsUpdated);
        handleDocuments(snapshot, _recommendations);

        if ((_recommendationsUpdated.isNotEmpty && _recommendations.isEmpty) || _recommendationsUpdated.length >= _recommendations.length) {
          for (final updatedItem in _recommendationsUpdated) {
            for (final recommendationItem in _recommendations) {
              updatedItem.id == recommendationItem.id
                  ? updatedItem != recommendationItem
                      ? _recommendationsUpdatedContent.add(updatedItem)
                      : null
                  : null;
            }
          }
        } else {
          _recommendationsUpdatedContent.addAll(_recommendationsUpdated);
        }

        if (_recommendationsUpdatedContent.isNotEmpty) {
          if (_newNotificationIncoming(_recommendationsUpdatedContent)) {
            await _soundPlayer.playAsset(soundEnum: SoundsEnum.newCoachRecomendation);
          }
          emit(
            CoachRecommendationsUpdate(
              coachRecommendationContent: await getCoachRecommendationsData(coachRecommendationContent: _recommendationsUpdatedContent.toList()),
            ),
          );
        } else {
          emit(
            CoachRecommendationsSuccess(
              coachRecommendationList: await getCoachRecommendationsData(coachRecommendationContent: _recommendations.toList()),
            ),
          );
        }
      } catch (exception, stackTrace) {
        await Sentry.captureException(
          exception,
          stackTrace: stackTrace,
        );
        emit(CoachRecommendationsFailure(exception: exception));
      }
    }, onError: (dynamic error, StackTrace stackTrace) async {
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
      );
      emit(CoachRecommendationsFailure(exception: error));
    });
  }

  bool _newNotificationIncoming(Set<Recommendation> _recommendationsUpdatedContent) =>
      _recommendationsUpdatedContent.where((recommendation) => !recommendation.notificationViewed).toList().isNotEmpty;

  Future<void> getStreamFromUser(String userId) async {
    if (subscription == null) {
      CoachRepository().getCoachAssignmentByUserId(userId).then(
        (coachAssignment) {
          if (coachAssignment != null &&
              coachAssignment.coachAssignmentStatus as int == CoachAssignmentStatusEnum.approved.index &&
              coachAssignment.coachId != null) {
            getStream(userId, coachAssignment.coachId);
          }
        },
      );
    }
  }

  void handleDocuments(QuerySnapshot<Map<String, dynamic>> snapshot, Set<Recommendation> _recommendations) {
    if (snapshot.docs.isNotEmpty) {
      for (final doc in snapshot.docs) {
        final Map<String, dynamic> content = doc.data();
        _recommendations.add(Recommendation.fromJson(content));
      }
    }
  }

  void handleDocumentChanges(QuerySnapshot<Map<String, dynamic>> snapshot, Set<Recommendation> _recommendationsUpdated) {
    if (snapshot.docChanges.isNotEmpty) {
      for (final doc in snapshot.docChanges) {
        final Map<String, dynamic> content = doc.doc.data();
        _recommendationsUpdated.add(Recommendation.fromJson(content));
      }
    }
  }

  void getCoachRecommendations(String userId, String coachId) async {
    try {
      emit(LoadingCoachRecommendations());
      final List<Recommendation> coachRecommendations = await _coachRepository.getCoachRecommendationsForUser(userId, coachId);
      final List<CoachRecommendationDefault> recommendationsFormatted = await getCoachRecommendationsData(coachRecommendationContent: coachRecommendations);
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
      final List<CoachRecommendationDefault> coachRecommendations = await _coachRepository.getRecommendationsInfo(coachRecommendationContent);
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

  void emitCoachRecommendationDispose() async {
    try {
      emit(CoachRecommendationsDispose(coachRecommendationListDisposeValue: []));
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
