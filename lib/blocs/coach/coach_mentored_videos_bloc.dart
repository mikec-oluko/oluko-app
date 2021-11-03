import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/annotations.dart';
import 'package:oluko_app/models/segment_submission.dart';
import 'package:oluko_app/repositories/coach_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class CoachMentoredVideosState {}

class Loading extends CoachMentoredVideosState {}

class CoachMentoredVideosSuccess extends CoachMentoredVideosState {
  CoachMentoredVideosSuccess({this.mentoredVideos});
  final List<Annotation> mentoredVideos;
}

class CoachMentoredVideosUpdated extends CoachMentoredVideosState {
  CoachMentoredVideosUpdated({this.mentoredVideos});
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
    subscription.cancel();
  }

//TODO: GET STREAM
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>> getStream(
      String userId, String coachId) {
    subscription ??=
        _coachRepository.getSubscription(userId, coachId).listen((snapshot) {
      List<Annotation> coachAnnotations = [];
      List<Annotation> coachAnnotationsUpdated = [];

      if (snapshot.docChanges.isNotEmpty) {
        for (var doc in snapshot.docChanges) {
          final Map<String, dynamic> content =
              doc.doc.data() as Map<String, dynamic>;
          coachAnnotationsUpdated.add(Annotation.fromJson(content));
        }
      }

      if (snapshot.docs.isNotEmpty) {
        for (var doc in snapshot.docs) {
          final Map<String, dynamic> content =
              doc.data() as Map<String, dynamic>;
          coachAnnotations.add(Annotation.fromJson(content));
        }
      }
      coachAnnotationsUpdated.forEach((elementUpdated) {
        if (coachAnnotations.contains(elementUpdated)) {
          coachAnnotationsUpdated.remove(elementUpdated);
        }
      });
      if (coachAnnotationsUpdated.isNotEmpty) {
        emit(CoachMentoredVideosUpdated(mentoredVideos: coachAnnotations));
      } else {
        emit(CoachMentoredVideosSuccess(mentoredVideos: coachAnnotations));
      }
    });
    return subscription;
  }

  // void getMentoredVideosByUserId(String userId, String coachId) async {
  //   try {
  //     final List<Annotation> coachAnnotations =
  //         await _coachRepository.getCoachAnnotationsByUserId(userId, coachId);
  //     emit(CoachMentoredVideosSuccess(mentoredVideos: coachAnnotations));
  //   } catch (exception, stackTrace) {
  //     await Sentry.captureException(
  //       exception,
  //       stackTrace: stackTrace,
  //     );
  //     emit(CoachMentoredVideoFailure(exception: exception));
  //     rethrow;
  //   }
  // }

  void updateCoachAnnotationFavoriteValue(
      {Annotation coachAnnotation,
      List<Annotation> currentMentoredVideosContent}) async {
    try {
      final List<Annotation> coachAnnotationsUpdated =
          await _coachRepository.setAnnotationAsFavorite(
              coachAnnotation, currentMentoredVideosContent);
      emit(CoachMentoredVideosSuccess(mentoredVideos: coachAnnotationsUpdated));
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
      await _coachRepository.updateMentoredVideoNotificationStatus(
          coachId, annotationId, notificationValue);
      //getMentoredVideosByUserId(userId, coachId);
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
