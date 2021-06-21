import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/models/assessment.dart';
import 'package:oluko_app/models/assessment_task.dart';
import 'package:oluko_app/models/task.dart';

class TaskRepository {
  FirebaseFirestore firestoreInstance;

  TaskRepository() {
    firestoreInstance = FirebaseFirestore.instance;
  }

  TaskRepository.test({FirebaseFirestore firestoreInstance}) {
    this.firestoreInstance = firestoreInstance;
  }

  Future<List<Task>> getAll() async {
    QuerySnapshot docRef = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue("projectId"))
        .collection('tasks')
        .get();
    List<Task> response = [];
    docRef.docs.forEach((doc) {
      final Map<String, dynamic> element = doc.data();
      response.add(Task.fromJson(element));
    });
    return response;
  }
}
