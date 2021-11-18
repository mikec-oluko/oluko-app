import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/helpers/coach_timeline_content.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class CoachTimelineState {}

class Loading extends CoachTimelineState {}

class CoachTimelineTabsException extends CoachTimelineState {
  CoachTimelineTabsException({this.exception});
  final dynamic exception;
}

class CoachTimelineTabsUpdate extends CoachTimelineState {
  CoachTimelineTabsUpdate({this.numberOfTabs, this.timelineContentItems});
  int numberOfTabs;
  List<CoachTimelineGroup> timelineContentItems;
}

class CoachTimelineBloc extends Cubit<CoachTimelineState> {
  CoachTimelineBloc() : super(Loading());

  void emitTimelineTabsUpdate({int numberOfTabsForPanel, List<CoachTimelineGroup> contentForTimelinePanel}) {
    try {
      emit(CoachTimelineTabsUpdate(numberOfTabs: numberOfTabsForPanel, timelineContentItems: contentForTimelinePanel));
    } catch (exception, stackTrace) {
      Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(CoachTimelineTabsException(exception: exception));
      rethrow;
    }
  }
}
