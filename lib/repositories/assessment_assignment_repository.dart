import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/models/assessment.dart';
import 'package:oluko_app/models/assessment_assignment.dart';

class AssessmentAssignmentRepository {
  FirebaseFirestore firestoreInstance;

  AssessmentAssignmentRepository() {
    this.firestoreInstance = FirebaseFirestore.instance;
  }

  static AssessmentAssignment create(String userId, Assessment assessment) {
    DocumentReference projectReference = FirebaseFirestore.instance.collection("projects").doc(GlobalConfiguration().getString('projectId'));

    CollectionReference assessmentAssignmentReference = projectReference.collection("assessmentAssignments");

    DocumentReference assessmentReference = projectReference.collection("assessment").doc(assessment.id);

    AssessmentAssignment assessmentAssignment = AssessmentAssignment(createdBy: userId, assessmentId: assessment.id, assessmentReference: assessmentReference);

    final DocumentReference docRef = assessmentAssignmentReference.doc();
    assessmentAssignment.id = docRef.id;
    docRef.set(assessmentAssignment.toJson());
    return assessmentAssignment;
  }

  static Future<AssessmentAssignment> getByUserId(String userId) async {
    QuerySnapshot docRef = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getString('projectId'))
        .collection('assessmentAssignments')
        .where('created_by', isEqualTo: userId)
        .get();

    if (docRef.docs.length > 0) {
      return AssessmentAssignment.fromJson(docRef.docs[0].data() as Map<String, dynamic>);
    } else {
      return null;
    }
  }

  static Future<Timestamp> setAsCompleted(String id) async {
    var completedAt = Timestamp.now();
    DocumentReference reference =
        FirebaseFirestore.instance.collection('projects').doc(GlobalConfiguration().getString('projectId')).collection('assessmentAssignments').doc(id);
    reference.update({
      'completed_at': completedAt,
    });
    return completedAt;
  }

  static Future<void> setAsSeen(String userId) async {
    QuerySnapshot docRef = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getString('projectId'))
        .collection('assessmentAssignments')
        .where('created_by', isEqualTo: userId)
        .get();

    AssessmentAssignment assessmentAssignment = AssessmentAssignment.fromJson(docRef.docs[0].data() as Map<String, dynamic>);

    DocumentReference reference = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getString('projectId'))
        .collection('assessmentAssignments')
        .doc(assessmentAssignment.id);

    reference.update({
      'seen_by_user': true,
    });
  }

  static Future<bool> setAsIncompleted(String id) async {
    DocumentReference reference =
        FirebaseFirestore.instance.collection('projects').doc(GlobalConfiguration().getString("projectId")).collection('assessmentAssignments').doc(id);
    reference.update({
      'completed_at': null,
    });
    return true;
  }
}
