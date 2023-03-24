import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/models/assessment.dart';

class AssessmentRepository {
  FirebaseFirestore firestoreInstance;

  AssessmentRepository() {
    firestoreInstance = FirebaseFirestore.instance;
  }

  AssessmentRepository.test({FirebaseFirestore firestoreInstance}) {
    this.firestoreInstance = firestoreInstance;
  }

  Future<List<Assessment>> getAll() async {
    QuerySnapshot docRef =
        await FirebaseFirestore.instance.collection('projects').doc(GlobalConfiguration().getString('projectId')).collection('assessments').get();
    List<Assessment> response = [];
    docRef.docs.forEach((doc) {
      final Map<String, dynamic> element = doc.data() as Map<String, dynamic>;
      response.add(Assessment.fromJson(element));
    });
    return response;
  }

  Future<Assessment> getById(String id) async {
    QuerySnapshot docRef = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getString('projectId'))
        .collection('assessments')
        .where('id', isEqualTo: id)
        .get();
    if (docRef.docs.length > 0) {
      return Assessment.fromJson(docRef.docs[0].data() as Map<String, dynamic>);
    } else {
      return null;
    }
  }
}
