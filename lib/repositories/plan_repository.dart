import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mvt_fitness/models/plan.dart';

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
      final Map<String, dynamic> element = doc.data();
      response.add(Plan.fromJson(element));
    });
    return response;
  }
}
