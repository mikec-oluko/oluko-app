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

class CoachMentoredVideoFailure extends CoachMentoredVideosState {
  CoachMentoredVideoFailure({this.exception});
  final dynamic exception;
}

class CoachMentoredVideosBloc extends Cubit<CoachMentoredVideosState> {
  CoachMentoredVideosBloc() : super(Loading());

  void getMentoredVideosByUserId(String userId, String coachId) async {
    try {
      final List<Annotation> coachAnnotations = await CoachRepository().getCoachAnnotationsByUserId(userId, coachId);
      emit(CoachMentoredVideosSuccess(mentoredVideos: coachAnnotations));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(CoachMentoredVideoFailure(exception: exception));
      rethrow;
    }
  }

  void updateCoachAnnotationFavoriteValue(
      {Annotation coachAnnotation, List<Annotation> currentMentoredVideosContent}) async {
    try {
      final List<Annotation> coachAnnotationsUpdated =
          await CoachRepository().setAnnotationAsFavorite(coachAnnotation, currentMentoredVideosContent);
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
}
