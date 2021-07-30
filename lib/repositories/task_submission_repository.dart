import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/models/assessment_assignment.dart';
import 'package:oluko_app/models/task.dart';
import 'package:oluko_app/models/task_submission.dart';
import 'package:oluko_app/models/submodels/video.dart';

class TaskSubmissionRepository {
  static DocumentReference projectReference = FirebaseFirestore.instance
      .collection("projects")
      .doc(GlobalConfiguration().getValue("projectId"));

  FirebaseFirestore firestoreInstance;

  TaskSubmissionRepository() {
    this.firestoreInstance = FirebaseFirestore.instance;
  }

  static TaskSubmission createTaskSubmission(
      AssessmentAssignment assessmentAssignment, Task task) {
    DocumentReference assessmentAReference = projectReference
        .collection('assessmentAssignments')
        .doc(assessmentAssignment.id);

    DocumentReference taskReference =
        projectReference.collection("tasks").doc(task.id);

    TaskSubmission taskSubmission =
        TaskSubmission(taskId: task.id, taskReference: taskReference);

    CollectionReference reference =
        assessmentAReference.collection('taskSubmissions');

    final DocumentReference docRef = reference.doc();
    taskSubmission.id = docRef.id;
    docRef.set(taskSubmission.toJson());
    return taskSubmission;
  }

  static updateTaskSubmissionVideo(
      AssessmentAssignment assessmentA, String id, Video video) async {
    DocumentReference reference = projectReference
        .collection('assessmentAssignments')
        .doc(assessmentA.id)
        .collection('taskSubmissions')
        .doc(id);
    reference.update({'video': video.toJson()});
  }

  static Future<TaskSubmission> getTaskSubmissionOfTask(
      AssessmentAssignment assessmentAssignment, Task task) async {
    CollectionReference reference = projectReference
        .collection("assessmentAssignments")
        .doc(assessmentAssignment.id)
        .collection('taskSubmissions');
    final querySnapshot =
        await reference.where("task_id", isEqualTo: task.id).get();
    if (querySnapshot.docs.length > 0) {
      print("--------------------------------------------");
      print(querySnapshot.docs[0].data());
      return TaskSubmission.fromJson(querySnapshot.docs[0].data());
    }
    return null;
  }

  static Future<List<TaskSubmission>> getTaskSubmissionsByUserId(
      String userId) async {
    //TODO: Get all TaskSubmissions by assessmentsAssignments id
    List<String> _assessmentsIdList = [];
    List<TaskSubmission> response = [];
    QuerySnapshot<Object> docRef =
        await getAssessmentAssignmentsForUserId(userId);

    if (docRef.docs.length > 0) {
      docRef.docs.forEach((element) {
        String _assessmentId = element.id;
        _assessmentsIdList.add(_assessmentId);
      });
    }
    try {
      var futures = <Future>[];
      for (var asessmentId in _assessmentsIdList) {
        futures
            .add(await getTaskSubmissionsByAssessmentId(asessmentId, response));
      }
      Future.wait(futures);
    } catch (e) {
      return [];
    }
    return response;
  }

  static Future<QuerySnapshot<Object>> getAssessmentAssignmentsForUserId(
      String userId) async {
    QuerySnapshot docRef = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue("projectId"))
        .collection('assessmentAssignments')
        .where('user_id', isEqualTo: userId)
        .get();
    return docRef;
  }

  static Future getTaskSubmissionsByAssessmentId(
      String assessmentsId, List<TaskSubmission> response) async {
    CollectionReference reference = projectReference
        .collection("assessmentAssignments")
        .doc(assessmentsId)
        .collection('taskSubmissions');
    final querySnapshot = await reference.get();
    if (querySnapshot.docs.length > 0) {
      response.add(TaskSubmission.fromJson(querySnapshot.docs[0].data()));
    }
  }
}
