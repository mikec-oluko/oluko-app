import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/models/assessment.dart';
import 'package:oluko_app/models/assessment_assignment.dart';

class AssessmentAssignmentRepository {
  FirebaseFirestore firestoreInstance;

  AssessmentAssignmentRepository() {
    this.firestoreInstance = FirebaseFirestore.instance;
  }

  static AssessmentAssignment create(User user, Assessment assessment) {
    DocumentReference projectReference = FirebaseFirestore.instance
        .collection("projects")
        .doc(GlobalConfiguration().getValue("projectId"));

    CollectionReference assessmentAssignmentReference =
        projectReference.collection("assessmentAssignments");

    DocumentReference assessmentReference =
        projectReference.collection("assessment").doc(assessment.id);

    AssessmentAssignment assessmentAssignment = AssessmentAssignment(
        createdBy: user.uid,
        assessmentId: assessment.id,
        assessmentReference: assessmentReference);

    final DocumentReference docRef = assessmentAssignmentReference.doc();
    assessmentAssignment.id = docRef.id;
    docRef.set(assessmentAssignment.toJson());
    return assessmentAssignment;
  }

  static Future<AssessmentAssignment> getByUserId(String userId) async {
    QuerySnapshot docRef = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue("projectId"))
        .collection('assessmentAssignments')
        .where('created_by', isEqualTo: userId)
        .get();

    if (docRef.docs.length > 0) {
      return AssessmentAssignment.fromJson(
          docRef.docs[0].data() as Map<String, dynamic>);
    } else {
      return null;
    }
  }

  static Future<bool> setAsCompleted(String id) async {
    DocumentReference reference = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue("projectId"))
        .collection('assessmentAssignments')
        .doc(id);
    reference.update({
      'compleated_at': Timestamp.now(),
    });
    return true;
  }
}
