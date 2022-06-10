import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/coach_media_message.dart';
import 'package:oluko_app/repositories/coach_video_message_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class CoachVideoMessageState {}

class Loading extends CoachVideoMessageState {}

class CoachVideoMessageSuccess extends CoachVideoMessageState {
  CoachVideoMessageSuccess({this.coachVideoMessages});
  final List<CoachMediaMessage> coachVideoMessages;
}

class CoachVideoMessageDispose extends CoachVideoMessageState {
  CoachVideoMessageDispose({this.coachVideoMessagesDisposeValue});
  final List<CoachMediaMessage> coachVideoMessagesDisposeValue;
}

class CoachVideoMessagesFailure extends CoachVideoMessageState {
  CoachVideoMessagesFailure({this.exception});
  final dynamic exception;
}

class CoachVideoMessageBloc extends Cubit<CoachVideoMessageState> {
  CoachVideoMessageBloc() : super(Loading());
  final CoachVideoMessageRepository _coachVideoMessageRepository = CoachVideoMessageRepository();
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>> subscription;
  @override
  void dispose() {
    if (subscription != null) {
      subscription.cancel();
      subscription = null;
      _emitCoachVideoMessageDispose();
    }
  }

  Future<StreamSubscription<QuerySnapshot<Map<String, dynamic>>>> getStream({@required String userId, @required String coachId}) async {
    try {
      return subscription ??= _coachVideoMessageRepository.getStream(userId: userId, coachId: coachId).listen((snapshot) {
        List<CoachMediaMessage> videoMessages = [];
        emit(Loading());
        if (snapshot.docs.isNotEmpty) {
          for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in snapshot.docs) {
            final Map<String, dynamic> videoMessage = doc.data() as Map<String, dynamic>;
            videoMessages.add(CoachMediaMessage.fromJson(videoMessage));
          }
        }
        emit(CoachVideoMessageSuccess(coachVideoMessages: videoMessages.toList()));
      });
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(CoachVideoMessagesFailure(exception: exception));
      rethrow;
    }
  }

  void _emitCoachVideoMessageDispose() async {
    try {
      emit(CoachVideoMessageDispose(coachVideoMessagesDisposeValue: []));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(CoachVideoMessagesFailure(exception: exception));
      rethrow;
    }
  }

  Future<void> markVideoMessageNotificationAsSeen({String userId, CoachMediaMessage messageVideoContent}) async {
    try {
      await _coachVideoMessageRepository.markVideoMessageAsSeeen(userId: userId, messageVideoContent: messageVideoContent);
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(CoachVideoMessagesFailure(exception: exception));
      rethrow;
    }
  }
}
