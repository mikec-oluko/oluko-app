import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/models/assessment.dart';
import 'package:oluko_app/models/submodels/assessment_task.dart';
import 'package:oluko_app/models/task.dart';

class TaskRepository {
  FirebaseFirestore firestoreInstance;

  TaskRepository() {
    firestoreInstance = FirebaseFirestore.instance;
  }

  TaskRepository.test({FirebaseFirestore firestoreInstance}) {
    this.firestoreInstance = firestoreInstance;
  }

  static Future<List<Task>> getAll() async {
    QuerySnapshot docRef = await FirebaseFirestore.instance.collection('projects').doc(GlobalConfiguration().getString('projectId')).collection('tasks').get();
    return mapQueryToTask(docRef);
  }

  static Future<List<Task>> getAllByAssessment(Assessment assessment) async {
    List<Task> tasks = await getAll();
    List<String> taskIds = assessment.tasks.map((AssessmentTask assessmentTask) => assessmentTask.taskId).toList();

    List<Task> response = [];
    response.length = taskIds.length;
    tasks.forEach((task) {
      int index = taskIds.indexOf(task.id);
      if (index != -1) {
        response[index] = task;
      }
    });
    return response;
  }

  static List<Task> mapQueryToTask(QuerySnapshot qs) {
    return qs.docs.map((DocumentSnapshot ds) {
      return Task.fromJson(ds.data() as Map<String, dynamic>);
    }).toList();
  }
}
