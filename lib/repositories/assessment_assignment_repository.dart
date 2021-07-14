import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/models/assessment_assignment.dart';

class AssessmentAssignmentRepository {
  FirebaseFirestore firestoreInstance;

  AssessmentAssignmentRepository() {
    this.firestoreInstance = FirebaseFirestore.instance;
  }

  static AssessmentAssignment createAssessmentAsignment(
      AssessmentAssignment assessmentAssignment,
      CollectionReference reference) {
    /*String projectId = GlobalConfiguration().getValue("projectId");
    CollectionReference reference = FirebaseFirestore.instance
        .collection("projects")
        .doc(projectId)
        .collection("assessmentAssignments");*/
    final DocumentReference docRef = reference.doc();
    assessmentAssignment.id = docRef.id;
    docRef.set(assessmentAssignment.toJson());
    return assessmentAssignment;
  }

  Future<List<AssessmentAssignment>> getAll() async {
    QuerySnapshot docRef = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue("projectId"))
        .collection('assessmentAssignments')
        .get();
    List<AssessmentAssignment> response = [];
    docRef.docs.forEach((doc) {
      final Map<String, dynamic> element = doc.data();
      response.add(AssessmentAssignment.fromJson(element));
    });
    return response;
  }

  Future<List<AssessmentAssignment>> getById(String id) async {
    QuerySnapshot docRef = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue("projectId"))
        .collection('assessmentAssignments')
        .where('id', isEqualTo: id)
        .get();
    List<AssessmentAssignment> response = [];
    docRef.docs.forEach((doc) {
      final Map<String, dynamic> element = doc.data();
      response.add(AssessmentAssignment.fromJson(element));
    });
    return response;
  }

  Future<List<AssessmentAssignment>> getByUserId(String id) async {
    QuerySnapshot docRef = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue("projectId"))
        .collection('assessmentAssignments')
        .where('user_id', isEqualTo: id)
        .get();
    List<AssessmentAssignment> response = [];
    docRef.docs.forEach((doc) {
      final Map<String, dynamic> element = doc.data();
      response.add(AssessmentAssignment.fromJson(element));
    });
    return response;
  }

  Future<AssessmentAssignment> create(
      AssessmentAssignment assessmentAssignment) async {
    CollectionReference reference = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue("projectId"))
        .collection('assessmentAssignments');
    final DocumentReference docRef = reference.doc();
    assessmentAssignment.id = docRef.id;
    await docRef.set(assessmentAssignment.toJson());
    return assessmentAssignment;
  }
}
