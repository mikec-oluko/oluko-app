import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/coach_timeline_item.dart';
import 'package:oluko_app/repositories/coach_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class CoachTimelineItemsState {}

class Loading extends CoachTimelineItemsState {}

class CoachTimelineItemsSuccess extends CoachTimelineItemsState {
  CoachTimelineItemsSuccess({this.timelineItems});
  final List<CoachTimelineItem> timelineItems;
}

class CoachTimelineItemsFailure extends CoachTimelineItemsState {
  CoachTimelineItemsFailure({this.exception});
  final dynamic exception;
}

class CoachTimelineItemsBloc extends Cubit<CoachTimelineItemsState> {
  CoachTimelineItemsBloc() : super(Loading());

  void getTimelineItemsForUser(String userId) async {
    try {
      final List<CoachTimelineItem> timelineContent = await CoachRepository().getTimelineContent(userId);
      emit(CoachTimelineItemsSuccess(timelineItems: timelineContent));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(CoachTimelineItemsFailure(exception: exception));
      rethrow;
    }
  }
}
