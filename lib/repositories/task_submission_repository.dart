import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/models/task.dart';
import 'package:oluko_app/models/task_submission.dart';
import 'package:oluko_app/models/submodels/video.dart';

class TaskSubmissionRepository {
  FirebaseFirestore firestoreInstance;

  TaskSubmissionRepository() {
    this.firestoreInstance = FirebaseFirestore.instance;
  }

  static TaskSubmission createTaskSubmission(
      TaskSubmission taskSubmission, CollectionReference reference) {
    final DocumentReference docRef = reference.doc();
    taskSubmission.id = docRef.id;
    docRef.set(taskSubmission.toJson());
    return taskSubmission;
  }

  static updateTaskSubmissionVideo(
      Video video, DocumentReference reference) async {
    reference.update({'video': video.toJson()});
  }

  static Future<TaskSubmission> getTaskSubmissionOfTask(Task task) async {
    CollectionReference reference = FirebaseFirestore.instance
        .collection("projects")
        .doc(GlobalConfiguration().getValue("projectId"))
        .collection("assessmentAssignments")
        .doc('8dWwPNggqruMQr0OSV9f')
        .collection('taskSubmissions');
    final querySnapshot =
        await reference.where("task_id", isEqualTo: task.id).get();
    if (querySnapshot.docs.length > 0) {
      return TaskSubmission.fromJson(querySnapshot.docs[0].data());
    }
    return null;
  }

  static Future<List<TaskSubmission>> getTaskSubmissionsByUserName(
      String userName) async {
    QuerySnapshot docRef = await FirebaseFirestore.instance
        .collection("projects")
        .doc(GlobalConfiguration().getValue("projectId"))
        .collection("taskSubmissions")
        // .where('user_id', isEqualTo: userId)
        .get();

    List<TaskSubmission> response = [];
    docRef.docs.forEach((doc) {
      final Map<String, dynamic> element = doc.data();
      response.add(TaskSubmission.fromJson(element));
    });
    return response;
  }
}
