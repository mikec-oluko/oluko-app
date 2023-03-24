import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/models/submodels/video.dart';
import 'package:oluko_app/models/submodels/video_info.dart';
import 'package:oluko_app/models/task_review.dart';
import 'package:oluko_app/models/task_submission.dart';
import 'package:oluko_app/repositories/task_review_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class TaskReviewState {}

class Loading extends TaskReviewState {}

class CreateSuccess extends TaskReviewState {
  String taskReviewId;
  CreateSuccess({this.taskReviewId});
}

class UpdateSuccess extends TaskReviewState {}

class Failure extends TaskReviewState {
  final dynamic exception;

  Failure({this.exception});
}

class TaskReviewBloc extends Cubit<TaskReviewState> {
  TaskReviewBloc() : super(Loading());

  void createTaskReview(CollectionReference reference, TaskSubmission taskSubmission, String assessmentAssignmentId) {
    final DocumentReference taskSubmissionReference = FirebaseFirestore.instance
        .collection("projects")
        .doc(GlobalConfiguration().getString('projectId'))
        .collection("assessmentAssignments")
        .doc('assessmentAssignmentId')
        .collection('taskSubmissions')
        .doc(taskSubmission.id);
    try {
      TaskReview newTaskReview =
          TaskReview(videoInfo: VideoInfo(drawing: [], markers: [], events: [], video: Video()), taskSubmissionReference: taskSubmissionReference);
      newTaskReview = TaskReviewRepository.createTaskReview(newTaskReview, reference);
      emit(CreateSuccess(taskReviewId: newTaskReview.id));
    } catch (e, stackTrace) {
      Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      emit(Failure(exception: e));
      rethrow;
    }
  }

  void updateTaskReviewVideoInfo(DocumentReference reference, VideoInfo videoInfo) async {
    try {
      await TaskReviewRepository.updateTaskReviewVideoInfo(videoInfo, reference);
      emit(UpdateSuccess());
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      emit(Failure(exception: e));
      rethrow;
    }
  }
}
