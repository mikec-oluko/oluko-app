import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:mvt_fitness/models/assessment.dart';

class AssessmentRepository {
  FirebaseFirestore firestoreInstance;

  AssessmentRepository() {
    firestoreInstance = FirebaseFirestore.instance;
  }

  AssessmentRepository.test({FirebaseFirestore firestoreInstance}) {
    this.firestoreInstance = firestoreInstance;
  }

  Future<List<Assessment>> getAll() async {
    QuerySnapshot docRef = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue("projectId"))
        .collection('assessments')
        .get();
    List<Assessment> response = [];
    docRef.docs.forEach((doc) {
      final Map<String, dynamic> element = doc.data();
      response.add(Assessment.fromJson(element));
    });
    return response;
  }

  Future<List<Assessment>> getById(String id) async {
    QuerySnapshot docRef = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue("projectId"))
        .collection('assessments')
        .where('id', isEqualTo: id)
        .get();
    List<Assessment> response = [];
    docRef.docs.forEach((doc) {
      final Map<String, dynamic> element = doc.data();
      response.add(Assessment.fromJson(element));
    });
    return response;
  }
}
