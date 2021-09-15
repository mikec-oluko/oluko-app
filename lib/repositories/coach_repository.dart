import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/models/coach_assignment.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class CoachRepository {
  FirebaseFirestore firestoreInstance;

  CoachRepository() {
    firestoreInstance = FirebaseFirestore.instance;
  }

  CoachRepository.test({FirebaseFirestore firestoreInstance}) {
    this.firestoreInstance = firestoreInstance;
  }

  Future<CoachAssignment> getCoachAssignmentByUserId(String userId) async {
    final QuerySnapshot docRef = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue('projectId'))
        .collection('coachAssignment')
        .where('id', isEqualTo: userId)
        .get();
    if (docRef.docs == null || docRef.docs.isEmpty) {
      return null;
    }
    final response = docRef.docs[0].data() as Map<String, dynamic>;
    final coachAssignmentResponse = CoachAssignment.fromJson(response);
    return coachAssignmentResponse;
  }
}
