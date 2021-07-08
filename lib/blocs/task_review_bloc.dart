import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:mvt_fitness/models/submodels/video.dart';
import 'package:mvt_fitness/models/submodels/video_info.dart';
import 'package:mvt_fitness/models/task_review.dart';
import 'package:mvt_fitness/models/task_submission.dart';
import 'package:mvt_fitness/repositories/task_review_repository.dart';

abstract class TaskReviewState {}

class Loading extends TaskReviewState {}

class CreateSuccess extends TaskReviewState {
  String taskReviewId;
  CreateSuccess({this.taskReviewId});
}

class UpdateSuccess extends TaskReviewState {}

class Failure extends TaskReviewState {
  final Exception exception;

  Failure({this.exception});
}

class TaskReviewBloc extends Cubit<TaskReviewState> {
  TaskReviewBloc() : super(Loading());

  void createTaskReview(CollectionReference reference,
      TaskSubmission taskSubmission, String assessmentAssignmentId) {
    final DocumentReference taskSubmissionReference = FirebaseFirestore.instance
        .collection("projects")
        .doc(GlobalConfiguration().getValue("projectId"))
        .collection("assessmentAssignments")
        .doc('assessmentAssignmentId')
        .collection('taskSubmissions')
        .doc(taskSubmission.id);
    try {
      TaskReview newTaskReview = TaskReview(
          videoInfo:
              VideoInfo(drawing: [], markers: [], events: [], video: Video()),
          taskSubmissionReference: taskSubmissionReference);
      newTaskReview =
          TaskReviewRepository.createTaskReview(newTaskReview, reference);
      emit(CreateSuccess(taskReviewId: newTaskReview.id));
    } catch (e) {
      emit(Failure(exception: e));
    }
  }

  void updateTaskReviewVideoInfo(
      DocumentReference reference, VideoInfo videoInfo) async {
    try {
      await TaskReviewRepository.updateTaskReviewVideoInfo(
          videoInfo, reference);
      emit(UpdateSuccess());
    } catch (e) {
      emit(Failure(exception: e));
    }
  }
}
