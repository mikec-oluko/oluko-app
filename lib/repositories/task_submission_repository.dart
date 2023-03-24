import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/models/assessment_assignment.dart';
import 'package:oluko_app/models/submodels/object_submodel.dart';
import 'package:oluko_app/models/task.dart';
import 'package:oluko_app/models/task_submission.dart';
import 'package:oluko_app/models/submodels/video.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/repositories/user_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class TaskSubmissionRepository {
  static DocumentReference projectReference = FirebaseFirestore.instance.collection("projects").doc(GlobalConfiguration().getString('projectId'));

  FirebaseFirestore firestoreInstance;

  TaskSubmissionRepository() {
    this.firestoreInstance = FirebaseFirestore.instance;
  }

  static Future<TaskSubmission> createTaskSubmission(AssessmentAssignment assessmentAssignment, Task task, bool isPublic, bool isLastTask) async {
    DocumentReference assessmentAReference = projectReference.collection('assessmentAssignments').doc(assessmentAssignment.id);

    DocumentReference taskReference = projectReference.collection("tasks").doc(task.id);

    ObjectSubmodel taskSubmodel = ObjectSubmodel(id: task.id, reference: taskReference, name: task.name);

    TaskSubmission taskSubmission = TaskSubmission(task: taskSubmodel, isPublic: isPublic, createdBy: assessmentAssignment.createdBy);

    CollectionReference reference = assessmentAReference.collection('taskSubmissions');

    final DocumentReference docRef = reference.doc();

    taskSubmission.id = docRef.id;

    docRef.set(taskSubmission.toJson());
    if (isLastTask != null && isLastTask) {
      UserResponse userToUpdate = await UserRepository().getById(assessmentAssignment.createdBy);
      await UserRepository().updateUserLastAssessmentUploaded(userToUpdate, Timestamp.now());
    }
    return taskSubmission;
  }

  static Future<TaskSubmission> createTaskSubmissionUpdated(
      {@required AssessmentAssignment assessmentAssignment, @required Task task, bool isPublic = true, @required bool isLastTask}) async {
    DocumentReference _taskReference = projectReference.collection('tasks').doc(task.id);
    ObjectSubmodel _taskSubmodel = ObjectSubmodel(id: task.id, reference: _taskReference, name: task.name);
    TaskSubmission taskSubmission = TaskSubmission(task: _taskSubmodel, isPublic: isPublic, createdBy: assessmentAssignment.createdBy);
    DocumentReference _assessmentAssignmentReference = projectReference.collection('assessmentAssignments').doc(assessmentAssignment.id);
    CollectionReference _taskSubmissionColReference = _assessmentAssignmentReference.collection('taskSubmissions');
    final DocumentReference _taskSubmissionDocReference = _taskSubmissionColReference.doc();
    taskSubmission.id = _taskSubmissionDocReference.id;
    return taskSubmission;
  }

  static Future<bool> saveTaskSubmission(AssessmentAssignment assessmentA, TaskSubmission taskSubmission, Video video, bool isLastTask) async {
    DocumentReference reference = projectReference.collection('assessmentAssignments').doc(assessmentA.id).collection('taskSubmissions').doc(taskSubmission.id);
    try {
      taskSubmission.video = video;
      DocumentSnapshot<Object> taskSubmitted = await reference.get();
      if (taskSubmitted.exists) {
        Map<String, dynamic> data = taskSubmitted.data() as Map<String, dynamic>;
        TaskSubmission existingTask = TaskSubmission.fromJson(data);
        if (existingTask.video != taskSubmission.video) {
          reference.update({'video': taskSubmission.video.toJson()});
        }
      } else {
        reference.set(taskSubmission.toJson());
      }
      if (isLastTask != null && isLastTask) {
        UserResponse userToUpdate = await UserRepository().getById(taskSubmission.createdBy);
        await UserRepository().updateUserLastAssessmentUploaded(userToUpdate, Timestamp.now());
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  static updateTaskSubmissionVideo(AssessmentAssignment assessmentA, String id, Video video) async {
    DocumentReference reference = projectReference.collection('assessmentAssignments').doc(assessmentA.id).collection('taskSubmissions').doc(id);
    reference.update({'video': video.toJson()});
  }

  static updateTaskSubmissionPrivacity(AssessmentAssignment assessmentA, String id, bool isPublic) async {
    DocumentReference reference = projectReference.collection('assessmentAssignments').doc(assessmentA.id).collection('taskSubmissions').doc(id);
    reference.update({'is_public': isPublic});
  }

  static Future<List<TaskSubmission>> getTaskSubmissions(AssessmentAssignment assessmentAssignment) async {
    CollectionReference reference = projectReference.collection("assessmentAssignments").doc(assessmentAssignment.id).collection('taskSubmissions');
    QuerySnapshot qs = await reference.get();
    return mapQueryTaskSubmission(qs);
  }

  static List<TaskSubmission> mapQueryTaskSubmission(QuerySnapshot qs) {
    List<TaskSubmission> tasksSubmitted = qs.docs.map((DocumentSnapshot ds) {
      Map<String, dynamic> data = ds.data() as Map<String, dynamic>;
      return TaskSubmission.fromJson(data);
    }).toList();
    List<TaskSubmission> tasksSubmittedFiltered = [];
    tasksSubmitted.forEach((element) {
      if (tasksSubmittedFiltered.isEmpty) {
        tasksSubmittedFiltered.add(element);
      } else {
        var taskFiltered = tasksSubmittedFiltered.firstWhere((elementFiltered) => elementFiltered.task.id == element.task.id, orElse: () => null);
        if (taskFiltered == null) {
          tasksSubmittedFiltered.add(element);
        } else {
          if (taskFiltered.createdAt.toDate().isBefore(element.createdAt.toDate())) {
            tasksSubmittedFiltered.remove(taskFiltered);
            tasksSubmittedFiltered.add(element);
          }
          ;
        }
      }
    });
    return tasksSubmittedFiltered;
  }

  static Future<List<TaskSubmission>> getTaskSubmissionsByUserId(String userId) async {
    List<String> _assessmentsIdList = [];
    List<TaskSubmission> response = [];

    QuerySnapshot<Object> docRef = await getAssessmentAssignmentsForUserId(userId);

    if (docRef.docs.length > 0) {
      docRef.docs.forEach((doc) {
        String _assessmentId = doc.id;
        _assessmentsIdList.add(_assessmentId);
      });
    }

    try {
      for (var asessmentId in _assessmentsIdList) {
        await getTaskSubmissionsByAssessmentId(userId, asessmentId, response);
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
    return response;
  }

  static Future<QuerySnapshot<Object>> getAssessmentAssignmentsForUserId(String userId) async {
    QuerySnapshot docRef = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getString('projectId'))
        .collection('assessmentAssignments')
        .where('created_by', isEqualTo: userId)
        .get();
    return docRef;
  }

  static Future getTaskSubmissionsByAssessmentId(String userId, String assessmentId, List<TaskSubmission> response) async {
    try {
      CollectionReference reference = projectReference.collection("assessmentAssignments").doc(assessmentId).collection('taskSubmissions');
      final querySnapshot = await reference.where('created_by', isEqualTo: userId).where('video', isNotEqualTo: null).get();

      if (querySnapshot.docs.length > 0) {
        querySnapshot.docs.forEach((taskUploaded) {
          response.add(TaskSubmission.fromJson(taskUploaded.data() as Map<String, dynamic>));
        });
      }
    } catch (e) {
      print(e.toString());
      rethrow;
    }
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getTaskSubmissionOfTaskSubscription(AssessmentAssignment assessmentAssignment, Task task) {
    Stream<QuerySnapshot<Map<String, dynamic>>> taskSubmissionStream = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getString('projectId'))
        .collection('assessmentAssignments')
        .where('task.id', isEqualTo: task.id)
        .snapshots();
    return taskSubmissionStream;
  }

  static Future<TaskSubmission> getTaskSubmissionOfTask(AssessmentAssignment assessmentAssignment, String taskId) async {
    CollectionReference reference = projectReference.collection("assessmentAssignments").doc(assessmentAssignment.id).collection('taskSubmissions');
    final querySnapshot = await reference.where("task.id", isEqualTo: taskId).get();
    if (querySnapshot.docs.length > 0) {
      var mapped = mapQueryTaskSubmission(querySnapshot);
      // querySnapshot.docs.sort((a, b) {
      //   return -((a.data() as Map<String, dynamic>)['created_at'] as Timestamp)
      //       .toDate()
      //       .compareTo(((b.data() as Map<String, dynamic>)['created_at'] as Timestamp).toDate());
      // });
      return mapped[0];
    }
    return null;
  }
}
