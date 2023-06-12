import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/challenge.dart';
import 'package:oluko_app/models/coach_request.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/segment.dart';
import 'package:oluko_app/models/segment_submission.dart';
import 'package:oluko_app/models/utils/weight_helper.dart';
import 'package:oluko_app/models/weight_record.dart';
import 'package:oluko_app/repositories/segment_submission_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class SegmentSubmissionState {}

class Loading extends SegmentSubmissionState {}

class CreateSuccess extends SegmentSubmissionState {
  SegmentSubmission segmentSubmission;
  CreateSuccess({this.segmentSubmission});
}

class UpdateSegmentSubmissionSuccess extends SegmentSubmissionState {
  SegmentSubmission segmentSubmission;
  UpdateSegmentSubmissionSuccess({this.segmentSubmission});
}

class SaveSegmentSubmissionSuccess extends SegmentSubmissionState {
  SegmentSubmission segmentSubmission;
  SaveSegmentSubmissionSuccess({this.segmentSubmission});
}

class EncodedSegmentSubmissionSuccess extends SegmentSubmissionState {}

class ErrorSegmentSubmissionSuccess extends SegmentSubmissionState {}

class Failure extends SegmentSubmissionState {
  final dynamic exception;

  Failure({this.exception});
}

class CourseEnrollmentListSuccess extends SegmentSubmissionState {
  final List<CourseEnrollment> courseEnrollmentList;

  CourseEnrollmentListSuccess({this.courseEnrollmentList});
}

class SegmentSubmissionBloc extends Cubit<SegmentSubmissionState> {
  SegmentSubmissionBloc() : super(Loading());

  void create(
      User user, CourseEnrollment courseEnrollment, Segment segment, String videoPath, String coachId, String classId, CoachRequest coachRequest) async {
    try {
      SegmentSubmission segmentSubmission =
          await SegmentSubmissionRepository.create(user, courseEnrollment, segment, videoPath, coachId, classId, coachRequest);
      emit(CreateSuccess(segmentSubmission: segmentSubmission));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(Failure(exception: exception));
      rethrow;
    }
  }

  void setIsDeleted(SegmentSubmission segmentSubmission, bool deleted) async {
    try {
      await SegmentSubmissionRepository.setIsDeleted(segmentSubmission, deleted);
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(Failure(exception: exception));
      rethrow;
    }
  }

  void updateVideo(SegmentSubmission segmentSubmission) async {
    try {
      await SegmentSubmissionRepository.updateVideo(segmentSubmission);
      emit(UpdateSegmentSubmissionSuccess(segmentSubmission: segmentSubmission));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(Failure(exception: exception));
      rethrow;
    }
  }

  void updateSubmissionWeights(SegmentSubmission segmentSubmission, List<WeightRecord> submissionWeights) async {
    try {
      await SegmentSubmissionRepository.updateWeights(segmentSubmission, submissionWeights);
      emit(UpdateSegmentSubmissionSuccess(segmentSubmission: segmentSubmission));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(Failure(exception: exception));
      rethrow;
    }
  }

  void saveSegmentSubmissionWithVideo(SegmentSubmission segmentSubmission, CoachRequest coachRequest) async {
    try {
      await SegmentSubmissionRepository.saveSegmentSubmissionWithVideo(segmentSubmission, coachRequest);
      emit(SaveSegmentSubmissionSuccess(segmentSubmission: segmentSubmission));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(Failure(exception: exception));
      rethrow;
    }
  }

  void updateStateToEncoded(SegmentSubmission segmentSubmission) async {
    try {
      await SegmentSubmissionRepository.updateStateToEncoded(segmentSubmission);
      emit(EncodedSegmentSubmissionSuccess());
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(Failure(exception: exception));
      rethrow;
    }
  }

  void updateStateToError(SegmentSubmission segmentSubmission) async {
    try {
      await SegmentSubmissionRepository.updateStateToError(segmentSubmission);
      emit(ErrorSegmentSubmissionSuccess());
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(Failure(exception: exception));
      rethrow;
    }
  }
}
