import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class CoachReviewPendingState {}

class CoachReviewPendingLoading extends CoachReviewPendingState {}

class CoachReviewPendingSuccess extends CoachReviewPendingState {
  final num reviewsPending;
  CoachReviewPendingSuccess({this.reviewsPending});
}

class CoachReviewPendingFailure extends CoachReviewPendingState {
  final dynamic exception;
  CoachReviewPendingFailure({this.exception});
}

class CoachReviewPendingBloc extends Cubit<CoachReviewPendingState> {
  CoachReviewPendingBloc() : super(CoachReviewPendingLoading());

  void updateReviewPendingMessage(num numberOfPendingReviewItems) async {
    emit(CoachReviewPendingLoading());
    try {
      emit(CoachReviewPendingSuccess(reviewsPending: numberOfPendingReviewItems));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(CoachReviewPendingFailure(exception: exception));
      rethrow;
    }
  }
}
