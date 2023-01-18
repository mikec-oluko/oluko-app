import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/annotation.dart';
import 'package:oluko_app/repositories/coach_repository.dart';
import 'package:oluko_app/utils/sound_player.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class CoachMentoredVideosState {}

class Loading extends CoachMentoredVideosState {}

class CoachMentoredVideosSuccess extends CoachMentoredVideosState {
  CoachMentoredVideosSuccess({this.mentoredVideos});
  final List<Annotation> mentoredVideos;
}

class CoachMentoredVideosDispose extends CoachMentoredVideosState {
  CoachMentoredVideosDispose({this.mentoredVideosDisposeValue});
  final List<Annotation> mentoredVideosDisposeValue;
}

class CoachMentoredVideosUpdate extends CoachMentoredVideosState {
  CoachMentoredVideosUpdate({this.mentoredVideos});
  final List<Annotation> mentoredVideos;
}

class CoachMentoredVideoFailure extends CoachMentoredVideosState {
  CoachMentoredVideoFailure({this.exception});
  final dynamic exception;
}

class CoachMentoredVideosBloc extends Cubit<CoachMentoredVideosState> {
  final CoachRepository _coachRepository = CoachRepository();
  final SoundPlayer _soundPlayer = SoundPlayer();

  CoachMentoredVideosBloc() : super(Loading());

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>> subscription;

  @override
  void dispose() {
    if (subscription != null) {
      subscription.cancel();
      subscription = null;
      emitMentoredVideoDispose();
    }
  }

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>> getStream(String userId, String coachId) {
    return subscription ??= _coachRepository.getAnnotationSubscription(userId, coachId).listen((snapshot) async {
      final Set<Annotation> coachAnnotations = {};
      final Set<Annotation> coachAnnotationsUpdated = {};
      final Set<Annotation> coachAnnotationsChangedItems = {};
      try {
        handleDocumentChanges(snapshot, coachAnnotationsUpdated);
        handleDocuments(snapshot, coachAnnotations);

        if (coachAnnotationsUpdated.isNotEmpty && coachAnnotations.isNotEmpty) {
          for (final updateItem in coachAnnotationsUpdated) {
            for (final annotationItem in coachAnnotations) {
              if (annotationItem.id == updateItem.id) {
                if (updateItem != annotationItem) {
                  coachAnnotationsChangedItems.add(updateItem);
                }
              }
            }
          }
        } else {
          coachAnnotationsChangedItems.addAll(coachAnnotationsUpdated);
        }

        if (coachAnnotationsChangedItems.isNotEmpty) {
          emit(CoachMentoredVideosSuccess(mentoredVideos: coachAnnotationsChangedItems.toList()));
        } else {
          if (_newAnnotation(coachAnnotations, coachAnnotationsUpdated)) {
            await _soundPlayer.playAsset(soundEnum: SoundsEnum.newCoachRecomendation);
          }
          emit(CoachMentoredVideosSuccess(mentoredVideos: coachAnnotations.toList()));
        }
      } catch (exception, stackTrace) {
        await Sentry.captureException(
          exception,
          stackTrace: stackTrace,
        );
        emit(CoachMentoredVideoFailure(exception: exception));
      }
    }, onError: (dynamic error, StackTrace stackTrace) async {
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
      );
      emit(CoachMentoredVideoFailure(exception: error));
    });
  }

  bool _newAnnotation(Set<Annotation> coachAnnotations, Set<Annotation> coachAnnotationsUpdated) =>
      coachAnnotations.length != coachAnnotationsUpdated.length && !coachAnnotationsUpdated.first.notificationViewed;

  void handleDocuments(QuerySnapshot<Map<String, dynamic>> snapshot, Set<Annotation> coachAnnotations) {
    if (snapshot.docs.isNotEmpty) {
      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in snapshot.docs) {
        final Map<String, dynamic> content = doc.data() as Map<String, dynamic>;
        coachAnnotations.add(Annotation.fromJson(content));
      }
    }
  }

  void handleDocumentChanges(QuerySnapshot<Map<String, dynamic>> snapshot, Set<Annotation> coachAnnotationsUpdated) {
    if (snapshot.docChanges.isNotEmpty) {
      for (final DocumentChange<Map<String, dynamic>> doc in snapshot.docChanges) {
        final Map<String, dynamic> content = doc.doc.data() as Map<String, dynamic>;
        coachAnnotationsUpdated.add(Annotation.fromJson(content));
      }
    }
  }

  void updateCoachAnnotationFavoriteValue({Annotation coachAnnotation}) async {
    try {
      await _coachRepository.setAnnotationAsFavorite(coachAnnotation);
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(CoachMentoredVideoFailure(exception: exception));
      rethrow;
    }
  }

  void setMentoredVideoNotificationAsViewed(
    String coachId,
    String userId,
    String annotationId,
    bool notificationValue,
  ) async {
    try {
      await _coachRepository.updateMentoredVideoNotificationStatus(coachId, annotationId, notificationValue);
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(CoachMentoredVideoFailure(exception: exception));
      rethrow;
    }
  }

  void emitMentoredVideoDispose() async {
    try {
      emit(CoachMentoredVideosDispose(mentoredVideosDisposeValue: []));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(CoachMentoredVideoFailure(exception: exception));
      rethrow;
    }
  }
}
