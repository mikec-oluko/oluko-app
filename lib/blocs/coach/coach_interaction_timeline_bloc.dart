import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
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

class CoachTimelineItemsUpdate extends CoachTimelineItemsState {
  CoachTimelineItemsUpdate({this.timelineItems});
  final List<CoachTimelineItem> timelineItems;
}

class CoachTimelineItemsDispose extends CoachTimelineItemsState {
  CoachTimelineItemsDispose({this.timelineItemsDisposeValue});
  final List<CoachTimelineItem> timelineItemsDisposeValue;
}

class CoachTimelineItemsFailure extends CoachTimelineItemsState {
  CoachTimelineItemsFailure({this.exception});
  final dynamic exception;
}

class CoachTimelineItemsBloc extends Cubit<CoachTimelineItemsState> {
  CoachTimelineItemsBloc() : super(Loading());

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>> subscription;
  void dispose() {
    if (subscription != null) {
      subscription.cancel();
      subscription = null;
      emitTimelineItemsDispose();
    }
  }

  final CoachRepository _coachRepository = CoachRepository();

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>> getStream(String userId) {
    return subscription ??= _coachRepository.getTimelineItemsSubscription(userId).listen((snapshot) async {
      List<CoachTimelineItem> _timelineItems = [];
      List<CoachTimelineItem> _timelineItemsUpdated = [];
      List<CoachTimelineItem> _timelineItemsUpdatedContent = [];
      try {
        if (snapshot.docChanges.isNotEmpty) {
          snapshot.docChanges.forEach((doc) {
            final Map<String, dynamic> content = doc.doc.data();
            _timelineItemsUpdated.add(CoachTimelineItem.fromJson(content));
          });
        }
        if (snapshot.docs.isNotEmpty) {
          snapshot.docs.forEach((doc) {
            final Map<String, dynamic> content = doc.data();
            _timelineItems.add(CoachTimelineItem.fromJson(content));
          });
        }

        if (_timelineItemsUpdated.length >= _timelineItems.length) {
          _timelineItemsUpdated.forEach((updatedTimelineItem) {
            if (_timelineItems.where((timelineItem) => updatedTimelineItem.contentName == timelineItem.contentName).isEmpty) {
              _timelineItems.add(updatedTimelineItem);
            }
          });
        } else {
          _timelineItemsUpdatedContent.addAll(_timelineItemsUpdated);
        }

        _timelineItemsUpdatedContent.isNotEmpty
            ? emit(CoachTimelineItemsUpdate(
                timelineItems: await _coachRepository.getTimelineItemsReferenceContent(_timelineItemsUpdatedContent)))
            : emit(CoachTimelineItemsSuccess(timelineItems: await _coachRepository.getTimelineItemsReferenceContent(_timelineItems)));
      } catch (exception, stackTrace) {
        await Sentry.captureException(
          exception,
          stackTrace: stackTrace,
        );
        emit(CoachTimelineItemsFailure(exception: exception));
      }
    }, onError: (dynamic error, StackTrace stackTrace) async {
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
      );
      emit(CoachTimelineItemsFailure(exception: error));
    });
  }

  Future<List<CoachTimelineItem>> getTimelineItemsForUser(String userId) async {
    try {
      final List<CoachTimelineItem> timelineContent = await CoachRepository().getTimelineContent(userId);
      return timelineContent;
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(CoachTimelineItemsFailure(exception: exception));
      rethrow;
    }
  }

  void emitTimelineItemsDispose() async {
    try {
      emit(CoachTimelineItemsDispose(timelineItemsDisposeValue: []));
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
