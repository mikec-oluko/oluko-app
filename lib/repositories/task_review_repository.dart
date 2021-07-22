import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/submodels/video_info.dart';
import 'package:oluko_app/models/task_review.dart';

class TaskReviewRepository {
  FirebaseFirestore firestoreInstance;

  TaskReviewRepository() {
    this.firestoreInstance = FirebaseFirestore.instance;
  }

  static TaskReview createTaskReview(
      TaskReview taskReview, CollectionReference reference) {
    final DocumentReference docRef = reference.doc();
    taskReview.id = docRef.id;
    docRef.set(taskReview.toJson());
    return taskReview;
  }

  static updateTaskReviewVideoInfo(
      VideoInfo videoInfo, DocumentReference reference) async {
    reference.update({'video_info': videoInfo.toJson()});
  }
}
