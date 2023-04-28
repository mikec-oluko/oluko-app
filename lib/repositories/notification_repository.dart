import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/models/message.dart';

class NotificationRepository {
  FirebaseFirestore firestoreInstance;

  NotificationRepository() {
    firestoreInstance = FirebaseFirestore.instance;
  }

  NotificationRepository.test({FirebaseFirestore firestoreInstance}) {
    this.firestoreInstance = firestoreInstance;
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getNotificationSubscription(String userId) {
    Stream<QuerySnapshot<Map<String, dynamic>>> notificationsStream = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getString('projectId'))
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .where('is_deleted', isNotEqualTo: true)
        .snapshots();
    return notificationsStream;
  }

  static Future<void> clearAll(String userId) async {
    final notifications = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getString('projectId'))
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .where('is_deleted', isNotEqualTo: true)
        .get();
    for (final notification in notifications.docs) {
      if (notification.data()['seen_at'] == null) {
        await notification.reference.update({'seen_at': Timestamp.now()});
      }
    }
  }
}
