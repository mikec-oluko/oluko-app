import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/movement_submission.dart';
import 'package:oluko_app/models/segment_submission.dart';
import 'package:oluko_app/repositories/coach_repository.dart';
import 'package:oluko_app/repositories/movement_submission_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class CoachSentVideosState {}

class Loading extends CoachSentVideosState {}

class CoachSentVideosSuccess extends CoachSentVideosState {
  CoachSentVideosSuccess({this.sentVideos});
  final List<SegmentSubmission> sentVideos;
}

class CoachProfileFailure extends CoachSentVideosState {
  CoachProfileFailure({this.exception});
  final dynamic exception;
}

class CoachSentVideosBloc extends Cubit<CoachSentVideosState> {
  CoachSentVideosBloc() : super(Loading());

  void getSentVideosByUserId(String coachId) async {
    try {
      final List<SegmentSubmission> segmentsSubmitted = await CoachRepository().getSegmentsSubmitted(coachId);
      emit(CoachSentVideosSuccess(sentVideos: segmentsSubmitted));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(CoachProfileFailure(exception: exception));
      rethrow;
    }
  }
}
