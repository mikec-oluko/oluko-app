import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/models/assessment_assignment.dart';
import 'package:oluko_app/models/submodels/object_submodel.dart';
import 'package:oluko_app/models/task.dart';
import 'package:oluko_app/models/task_submission.dart';
import 'package:oluko_app/models/submodels/video.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/repositories/auth_repository.dart';

class TaskSubmissionRepository {
  static DocumentReference projectReference = FirebaseFirestore.instance
      .collection("projects")
      .doc(GlobalConfiguration().getValue("projectId"));

  FirebaseFirestore firestoreInstance;

  TaskSubmissionRepository() {
    this.firestoreInstance = FirebaseFirestore.instance;
  }

  static Future<TaskSubmission> createTaskSubmission(
      AssessmentAssignment assessmentAssignment,
      Task task,
      bool isPublic) async {
    DocumentReference assessmentAReference = projectReference
        .collection('assessmentAssignments')
        .doc(assessmentAssignment.id);

    DocumentReference taskReference =
        projectReference.collection("tasks").doc(task.id);

    ObjectSubmodel taskSubmodel =
        ObjectSubmodel(id: task.id, reference: taskReference, name: task.name);

    TaskSubmission taskSubmission = TaskSubmission(
        task: taskSubmodel,
        isPublic: isPublic,
        createdBy: assessmentAssignment.createdBy);

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
        await reference.where("task.id", isEqualTo: task.id).get();
    if (querySnapshot.docs.length > 0) {
      return TaskSubmission.fromJson(querySnapshot.docs[0].data());
    }
    return null;
  }

  static Future<List<TaskSubmission>> getTaskSubmissionsByUserId(
      String userId) async {
    List<String> _assessmentsIdList = [];
    List<TaskSubmission> response = [];

    QuerySnapshot<Object> docRef =
        await getAssessmentAssignmentsForUserId(userId);

    if (docRef.docs.length > 0) {
      docRef.docs.forEach((doc) {
        String _assessmentId = doc.id;
        _assessmentsIdList.add(_assessmentId);
      });
    }

    try {
      var futures = <Future>[];
      for (var asessmentId in _assessmentsIdList) {
        futures.add(await getTaskSubmissionsByAssessmentId(
            userId, asessmentId, response));
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
      String userId, String assessmentId, List<TaskSubmission> response) async {
    CollectionReference reference = projectReference
        .collection("assessmentAssignments")
        .doc(assessmentId)
        .collection('taskSubmissions');
    print(assessmentId);
    final querySnapshot = await reference
        .where('created_by', isEqualTo: userId)
        .where('video', isNotEqualTo: null)
        .get();

    if (querySnapshot.docs.length > 0) {
      response.add(TaskSubmission.fromJson(querySnapshot.docs[0].data()));
    }
  }
}
