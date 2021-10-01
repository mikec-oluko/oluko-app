import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/plan.dart';

class PlanRepository {
  FirebaseFirestore firestoreInstance;

  PlanRepository() {
    firestoreInstance = FirebaseFirestore.instance;
  }

  PlanRepository.test({FirebaseFirestore firestoreInstance}) {
    this.firestoreInstance = firestoreInstance;
  }

  Future<List<Plan>> getAll() async {
    QuerySnapshot docRef =
        await FirebaseFirestore.instance.collection('plans').get();
    List<Plan> response = [];
    docRef.docs.forEach((doc) {
      final Map<String, dynamic> element = doc.data() as Map<String, dynamic>;
      response.add(Plan.fromJson(element));
    });
    return response;
  }
}
