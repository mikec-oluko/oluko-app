import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/models/plan.dart';

class PlanRepository {
  FirebaseFirestore firestoreInstance;

  PlanRepository() {
    firestoreInstance = FirebaseFirestore.instance;
  }

  PlanRepository.test({FirebaseFirestore firestoreInstance}) {
    this.firestoreInstance = firestoreInstance;
  }

  static Future<List<Plan>> getAll() async {
    final DocumentReference projectReference = FirebaseFirestore.instance.collection('projects').doc(GlobalConfiguration().getString('projectId'));
    final QuerySnapshot docRef = await projectReference.collection('plans').where('active', isNotEqualTo: false).get();
    final List<Plan> response = mapQueryToPlan(docRef);
    return response;
  }

  static List<Plan> mapQueryToPlan(QuerySnapshot qs) {
    return qs.docs.map((DocumentSnapshot ds) {
      Map<String, dynamic> PlanData = ds.data() as Map<String, dynamic>;
      return Plan.fromJson(PlanData);
    }).toList();
  }
}
