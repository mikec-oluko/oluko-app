import 'package:cloud_firestore/cloud_firestore.dart';
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
    QuerySnapshot docRef =
        await FirebaseFirestore.instance.collection('tasks').get();
    List<Task> response = [];
    docRef.docs.forEach((doc) {
      final Map<String, dynamic> element = doc.data();
      response.add(Task.fromJson(element));
    });
    return response;
  }
}
