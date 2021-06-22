import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/task_submission.dart';

class TaskSubmissionRepository {
  FirebaseFirestore firestoreInstance;

  TaskSubmissionRepository() {
    this.firestoreInstance = FirebaseFirestore.instance;
  }

  static TaskSubmission createTaskSubmission(
      TaskSubmission taskResponse, CollectionReference reference) {
    final DocumentReference docRef = reference.doc();
    taskResponse.id = docRef.id;
    docRef.set(taskResponse.toJson());
    return taskResponse;
  }
}
