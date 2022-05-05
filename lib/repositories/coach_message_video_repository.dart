import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:global_configuration/global_configuration.dart';

class CoachMessageVideoRepository {
  FirebaseFirestore firestoreInstance;
  static DocumentReference projectReference =
      FirebaseFirestore.instance.collection('projects').doc(GlobalConfiguration().getValue('projectId'));

  CoachMessageVideoRepository() {
    firestoreInstance = FirebaseFirestore.instance;
  }
  CoachMessageVideoRepository.test({this.firestoreInstance});

  Stream<QuerySnapshot<Map<String, dynamic>>> getStream({@required String userId, @required String coachId}) {
    Stream<QuerySnapshot<Map<String, dynamic>>> coachMessageVideoStream = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue('projectId'))
        .collection('coachAssignments')
        .doc(userId)
        .collection('mediaMessages')
        .where('coach_id', isEqualTo: coachId)
        .snapshots();
    return coachMessageVideoStream;
  }
}
