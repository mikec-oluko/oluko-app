import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/assessment_assignment.dart';

class AssessmentAssignmentRepository {
  FirebaseFirestore firestoreInstance;

  AssessmentAssignmentRepository() {
    this.firestoreInstance = FirebaseFirestore.instance;
  }

  static AssessmentAssignment createAssessmentAsignment(
      AssessmentAssignment
          assessmentAssignment, CollectionReference reference) {
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
}
