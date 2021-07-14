import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/challenge.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/segment_submission.dart';
import 'package:oluko_app/repositories/segment_submission_repository.dart';

abstract class SegmentSubmissionState {}

class Loading extends SegmentSubmissionState {}

class CreateSuccess extends SegmentSubmissionState {
  SegmentSubmission segmentSubmission;
  CreateSuccess({this.segmentSubmission});
}

class Failure extends SegmentSubmissionState {
  final Exception exception;

  Failure({this.exception});
}

class GetCourseEnrollmentChallenge extends SegmentSubmissionState {
  final List<Challenge> challenges;

  GetCourseEnrollmentChallenge({this.challenges});
}

class CourseEnrollmentListSuccess extends SegmentSubmissionState {
  final List<CourseEnrollment> courseEnrollmentList;

  CourseEnrollmentListSuccess({this.courseEnrollmentList});
}

class SegmentSubmissionBloc extends Cubit<SegmentSubmissionState> {
  SegmentSubmissionBloc() : super(Loading());

  void create(User user, CourseEnrollment courseEnrollment) async {
    try {
      SegmentSubmission segmentSubmission =
          await SegmentSubmissionRepository.create(user, courseEnrollment);
      emit(CreateSuccess(segmentSubmission: segmentSubmission));
    } catch (e) {
      emit(Failure(exception: e));
    }
  }
}
