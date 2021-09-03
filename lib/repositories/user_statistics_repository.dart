import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/models/user_statistics.dart';

class UserStatisticsRepository {
  FirebaseFirestore firestoreInstance;

  UserStatisticsRepository() {
    firestoreInstance = FirebaseFirestore.instance;
  }

  UserStatisticsRepository.test({FirebaseFirestore firestoreInstance}) {
    this.firestoreInstance = firestoreInstance;
  }

  static Future<UserStatistics> getUserStatics(String userId) async {
    DocumentReference docRef = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue("projectId"))
        .collection('userStatistics')
        .doc(userId);
    DocumentSnapshot ds = await docRef.get();
    return UserStatistics.fromJson(ds.data());
  }
}
