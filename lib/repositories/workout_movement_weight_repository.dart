import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_configuration/global_configuration.dart';

class WorkoutMovementWeightRepository {
  FirebaseFirestore firestoreInstance;

  WorkoutMovementWeightRepository() {
    firestoreInstance = FirebaseFirestore.instance;
  }

  WorkoutMovementWeightRepository.test({FirebaseFirestore firestoreInstance}) {
    this.firestoreInstance = firestoreInstance;
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>> subscription;
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserWeightRecordsStream(String userId) {
    Stream<QuerySnapshot<Map<String, dynamic>>> userWeightRecorsStream = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue('projectId'))
        .collection('users')
        .doc(userId)
        .collection('records')
        .snapshots();
    return userWeightRecorsStream;
  }
}
