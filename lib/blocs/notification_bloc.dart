import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/message.dart';
import 'package:oluko_app/models/notification.dart';
import 'package:oluko_app/repositories/notification_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationSuccess extends NotificationState {
  final List<Notification> notifications;
  final int unseenNotifications;
  NotificationSuccess({this.notifications, this.unseenNotifications});
}

class NotificationFailure extends NotificationState {
  final dynamic exception;

  NotificationFailure({this.exception});
}

class NotificationBloc extends Cubit<NotificationState> {
  NotificationBloc() : super(NotificationLoading());

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>> subscription;
  void dispose() {
    if (subscription != null) {
      subscription.cancel();
      subscription = null;
    }
  }

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>> getStream(String userId) {
    return subscription ??= NotificationRepository.getNotificationSubscription(userId).listen((snapshot) async {
      final List<Notification> notifications = [];
      int unseenNotifications = 0;
      for (final doc in snapshot.docs) {
        final Map<String, dynamic> content = doc.data();
        final notification = Notification.fromJson(content);
        if (notification.message == Message().hifiveMessageCode && notification.isDeleted != true) {
          notifications.add(notification);
          if (notification.seenAt == null) {
            unseenNotifications++;
          }
        }
      }
      emit(NotificationSuccess(notifications: notifications, unseenNotifications: unseenNotifications));
    });
  }

  Future<void> clearAll(String userId) async {
    try {
      await NotificationRepository.clearAll(userId);
    } catch (exception, stackTrace) {
      Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(NotificationFailure(exception: exception));
      rethrow;
    }
  }
}
