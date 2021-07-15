import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/models/assessment_assignment.dart';

class AssessmentAssignmentRepository {
  FirebaseFirestore firestoreInstance;

  AssessmentAssignmentRepository() {
    this.firestoreInstance = FirebaseFirestore.instance;
  }

  static AssessmentAssignment create(User user) {
    DocumentReference projectReference = FirebaseFirestore.instance
        .collection("projects")
        .doc(GlobalConfiguration().getValue("projectId"));

    CollectionReference assessmentAssignmentReference =
        projectReference.collection("assessmentAssignments");

    DocumentReference userReference =
        projectReference.collection('users').doc(user.uid);

    AssessmentAssignment assessmentAssignment =
        AssessmentAssignment(userId: user.uid, userReference: userReference);

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
        .where('user_id', isEqualTo: userId)
        .get();

    if (docRef.docs.length > 0) {
      return AssessmentAssignment.fromJson(docRef.docs[0].data());
    } else {
      return null;
    }
  }
}
