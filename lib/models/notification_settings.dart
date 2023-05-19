import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class NotificationSettings {
  NotificationSettings({this.title, this.subtitle, this.type,
                        this.userId, this.segmentClocksSounds, this.globalNotifications,
                        this.workoutReminderNotifications, this.coachResponseNotifications, this.appOpeningReminderNotifications});

  String userId;
  bool segmentClocksSounds;
  bool globalNotifications;
  bool workoutReminderNotifications;
  bool coachResponseNotifications;
  bool appOpeningReminderNotifications;
  SettingsNotificationsOptions title;
  SettingsNotificationsOptions type;
  SettingsNotificationsSubtitle subtitle;

  static List<NotificationSettings> notificationSettingsList = [
    NotificationSettings(
      title: SettingsNotificationsOptions.globalNotifications,
      subtitle: SettingsNotificationsSubtitle.globalNotificationsSubtitle,
      type: SettingsNotificationsOptions.globalNotifications,
    ),
    NotificationSettings(
      title: SettingsNotificationsOptions.coachResponse,
      subtitle: SettingsNotificationsSubtitle.coachResponseSubtitle,
      type: SettingsNotificationsOptions.coachResponse,
    ),
    NotificationSettings(
      title: SettingsNotificationsOptions.workoutReminder,
      subtitle: SettingsNotificationsSubtitle.workoutReminderSubtitle,
      type: SettingsNotificationsOptions.workoutReminder,
    ),
    NotificationSettings(
      title: SettingsNotificationsOptions.appOpeningReminder,
      subtitle: SettingsNotificationsSubtitle.appOpeningReminderSubtitle,
      type: SettingsNotificationsOptions.appOpeningReminder,
    )
  ];

  bool getNotificationValue(SettingsNotificationsOptions type){
    switch (type) {
      case SettingsNotificationsOptions.globalNotifications:
        return globalNotifications;
      case SettingsNotificationsOptions.appOpeningReminder:
        return appOpeningReminderNotifications;
        case SettingsNotificationsOptions.workoutReminder:
        return workoutReminderNotifications;
      case SettingsNotificationsOptions.coachResponse:
        return coachResponseNotifications;
    }
    return true;
  }

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    final NotificationSettings chatJson = NotificationSettings(
      userId: json['user_id'] != null ? json['user_id'] as String : null,
      segmentClocksSounds: json['segment_clocks_sounds'] != null ? json['segment_clocks_sounds'] as bool : false,
      globalNotifications: json['global_notifications'] != null ? json['global_notifications'] as bool : false,
      workoutReminderNotifications: json['workout_reminder'] != null ? json['workout_reminder'] as bool : false,
      coachResponseNotifications: json['coach_response'] != null ? json['coach_response'] as bool : false,
      appOpeningReminderNotifications: json['app_opening_reminder'] != null ? json['app_opening_reminder'] as bool : false,
    );
    return chatJson;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> notiSettingsJson = {
      'user_id': userId,
      'segment_clocks_sounds': segmentClocksSounds,
      'global_notifications': globalNotifications,
      'workout_reminder': workoutReminderNotifications,
      'coach_response': coachResponseNotifications,
      'app_opening_reminder': appOpeningReminderNotifications
    };
    return notiSettingsJson;
  }
}
