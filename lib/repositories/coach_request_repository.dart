import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/models/coach_request.dart';

class CoachRequestRepository {
  FirebaseFirestore firestoreInstance;

  CoachRequestRepository() {
    firestoreInstance = FirebaseFirestore.instance;
  }

  CoachRequestRepository.test({this.firestoreInstance});

  Future<List<CoachRequest>> get(String userId) async {
    final docRef = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue('projectId'))
        .collection('coachAssignment')
        .doc(userId)
        .collection('coachRequests');
    final QuerySnapshot ds = await docRef.get();
    List<CoachRequest> response = [];
    ds.docs.forEach((doc) {
      final Map<String, dynamic> element = doc.data() as Map<String, dynamic>;
      response.add(CoachRequest.fromJson(element));
    });
    return response;
  }
}
