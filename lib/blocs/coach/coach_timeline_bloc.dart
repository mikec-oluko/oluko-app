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
  CoachTimelineTabsUpdate({this.timelineContentItems, this.isForFriend = false});
  List<CoachTimelineGroup> timelineContentItems;
  bool isForFriend;
}

class CoachTimelineBloc extends Cubit<CoachTimelineState> {
  CoachTimelineBloc() : super(Loading());

  void emitTimelineTabsUpdate({List<CoachTimelineGroup> contentForTimelinePanel, bool isForFriend = false}) {
    try {
      emit(CoachTimelineTabsUpdate(timelineContentItems: contentForTimelinePanel, isForFriend: isForFriend));
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
