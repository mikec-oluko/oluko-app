import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/models/user_statistics.dart';

class UserStatisticsRepository {
  FirebaseFirestore firestoreInstance;

  UserStatisticsRepository() {
    firestoreInstance = FirebaseFirestore.instance;
  }

  UserStatisticsRepository.test({this.firestoreInstance});

  static Future<UserStatistics> getUserStatics(String userId) async {
    final DocumentReference docRef =
        FirebaseFirestore.instance.collection('projects').doc(GlobalConfiguration().getString('projectId')).collection('userStatistics').doc(userId);
    DocumentSnapshot ds = await docRef.get();
    var doc = ds.data() as Map<String, dynamic>;
    if (doc != null) {
      return UserStatistics.fromJson(ds.data() as Map<String, dynamic>);
    }
    return UserStatistics(completedChallenges: 0, completedClasses: 0, completedCourses: 0, completedSegments: 0);
  }
}
