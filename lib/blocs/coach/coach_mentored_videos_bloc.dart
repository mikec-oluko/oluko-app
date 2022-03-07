import 'dart:async';
import 'package:collection/collection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/annotation.dart';
import 'package:oluko_app/models/segment_submission.dart';
import 'package:oluko_app/repositories/coach_repository.dart';
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
    return subscription ??= _coachRepository.getAnnotationSubscription(userId, coachId).listen((snapshot) {
      final Set<Annotation> coachAnnotations = {};
      final Set<Annotation> coachAnnotationsUpdated = {};

      handleDocumentChanges(snapshot, coachAnnotationsUpdated);
      handleDocuments(snapshot, coachAnnotations);

      final Set<Annotation> coachAnnotationsChangedItems = {};

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
        // emit(CoachMentoredVideosUpdate(mentoredVideos: coachAnnotationsChangedItems.toList())); //TODO: check if this is needed to control builds
        emit(CoachMentoredVideosSuccess(mentoredVideos: coachAnnotationsChangedItems.toList()));
      } else {
        emit(CoachMentoredVideosSuccess(mentoredVideos: coachAnnotations.toList()));
      }
    });
  }

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

  void updateCoachAnnotationFavoriteValue({Annotation coachAnnotation, Set<Annotation> currentMentoredVideosContent}) async {
    try {
      final Set<Annotation> coachAnnotationsUpdated =
          await _coachRepository.setAnnotationAsFavorite(coachAnnotation, currentMentoredVideosContent);
      emit(CoachMentoredVideosSuccess(mentoredVideos: coachAnnotationsUpdated.toList()));
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
