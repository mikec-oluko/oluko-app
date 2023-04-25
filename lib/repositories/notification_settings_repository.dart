import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/models/notification_settings.dart';

class NotificationSettingsRepository {
  FirebaseFirestore firestoreInstance;

  NotificationSettingsRepository() {
    firestoreInstance = FirebaseFirestore.instance;
  }

  NotificationSettingsRepository.test({FirebaseFirestore firestoreInstance}) {
    firestoreInstance = firestoreInstance;
  }

  static Future<NotificationSettings> getAll(String userId) async {
    final notificationSettings = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue('projectId'))
        .collection('notificationSettings')
        .doc(userId)
        .get();

    if (notificationSettings == null || notificationSettings.data() == null) {
      return NotificationSettings(globalNotifications: true, segmentClocksSounds: true, userId: userId,
                                  workoutReminderNotifications: true, coachResponseNotifications: true, appOpeningReminderNotifications: true);
    }

    return NotificationSettings.fromJson(Map<String, dynamic>.from(notificationSettings.data()));
  }

  static Future<NotificationSettings> updateNotificationSetting(NotificationSettings notiSetting) async {
    final notificationSetting = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue('projectId'))
        .collection('notificationSettings')
        .doc(notiSetting.userId)
        .get();
    if (notificationSetting.exists) {
      notificationSetting.reference.update(notiSetting.toJson());
    } else {
      notificationSetting.reference.set(notiSetting.toJson());
    }
    return notiSetting;
  }
}
