import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/notification_settings.dart';
import 'package:oluko_app/repositories/notification_settings_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class NotificationSettingsState {}

class NotificationSettingsLoading extends NotificationSettingsState {}

class NotificationSettingsSuccess extends NotificationSettingsState {
  NotificationSettings notificationSettings;
  NotificationSettingsSuccess({this.notificationSettings});
}

class NotificationSettingsUpdate extends NotificationSettingsState {
  NotificationSettings notificationSettings;
  NotificationSettingsUpdate({this.notificationSettings});
}

class NotificationFailure extends NotificationSettingsState {
  final dynamic exception;
  NotificationFailure({this.exception});
}

class NotificationSettingsBloc extends Cubit<NotificationSettingsState> {
  NotificationSettingsBloc() : super(NotificationSettingsLoading());

  static NotificationSettings notificationSettings;

  Future<NotificationSettings> get(String userId) async {
    try {
      notificationSettings ??= await NotificationSettingsRepository.getAll(userId);
      emit(NotificationSettingsSuccess(notificationSettings: notificationSettings));
      return notificationSettings;
    } catch (exception, stackTrace) {
      Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(NotificationFailure(exception: exception));
      rethrow;
    }
  }

  void update(NotificationSettings notiSettings) {
    try {
      notiSettings.globalNotifications ??= notificationSettings?.globalNotifications ?? true;
      notiSettings.appOpeningReminderNotifications ??= notificationSettings?.appOpeningReminderNotifications ?? true;
      notiSettings.coachResponseNotifications ??= notificationSettings?.coachResponseNotifications ?? true;
      notiSettings.workoutReminderNotifications ??= notificationSettings?.workoutReminderNotifications ?? true;
      notiSettings.segmentClocksSounds ??= notificationSettings?.segmentClocksSounds ?? true;
      notiSettings.userId ??= notificationSettings.userId;

      NotificationSettingsRepository.updateNotificationSetting(notiSettings).then((value) {
        notificationSettings = value;
        emit(NotificationSettingsUpdate(notificationSettings: notificationSettings));
      });
    } catch (exception, stackTrace) {
      Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(NotificationFailure(exception: exception));
      rethrow;
    }
  }

  static bool areGlobalNotificationEnabled() {
    return notificationSettings == null || notificationSettings.globalNotifications;
  }

  static bool areSegmentClockNotificationEnabled() {
    return notificationSettings == null || notificationSettings.segmentClocksSounds;
  }
}
