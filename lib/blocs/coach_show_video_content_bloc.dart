import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/segment.dart';
import 'package:oluko_app/models/segment_submission.dart';
import 'package:oluko_app/models/submodels/enrollment_class.dart';
import 'package:oluko_app/models/submodels/enrollment_segment.dart';
import 'package:oluko_app/models/weight_record.dart';
import 'package:oluko_app/repositories/course_enrollment_repository.dart';
import 'package:oluko_app/repositories/movement_repository.dart';
import 'package:oluko_app/repositories/segment_repository.dart';
import 'package:oluko_app/repositories/segment_submission_repository.dart';

abstract class CoachShowVideoContentState {}

class CoachShowVideoContentLoading extends CoachShowVideoContentState {}

class CoachShowVideoContentStateSuccess extends CoachShowVideoContentState {
  final Segment segment;
  final EnrollmentClass enrollmentClass;
  final EnrollmentSegment enrollmentSegment;
  final SegmentSubmission segmentSubmission;
  CoachShowVideoContentStateSuccess({this.segment, this.enrollmentClass, this.enrollmentSegment, this.segmentSubmission});
}

class Failure extends CoachShowVideoContentState {
  final dynamic exception;

  Failure({this.exception});
}

class CoachShowVideoContentBloc extends Cubit<CoachShowVideoContentState> {
  CoachShowVideoContentBloc() : super(CoachShowVideoContentLoading());

  Future<void> getContent(String segmentSubmissionId, String userId) async {
    try {
      final SegmentSubmission segmentSubmission = await SegmentSubmissionRepository().getById(segmentSubmissionId);
      final CourseEnrollment courseEnrollment = await CourseEnrollmentRepository.getById(segmentSubmission.courseEnrollmentId);
      EnrollmentClass enrollmentClass;
      EnrollmentSegment enrollmentSegment;
      bool next = true;

      for (int i = 0; i < courseEnrollment.classes.length && next; i++) {
        final index = courseEnrollment.classes[i].segments?.indexWhere((element) => element.id == segmentSubmission.segmentId);
        if (index != -1) {
          enrollmentClass = courseEnrollment.classes[i];
          enrollmentSegment = courseEnrollment.classes[i].segments[index];
          next = false;
        }
      }
      final Segment segment = await SegmentRepository.get(enrollmentSegment.id);
      emit(
        CoachShowVideoContentStateSuccess(
          enrollmentClass: enrollmentClass,
          enrollmentSegment: enrollmentSegment,
          segment: segment,
          segmentSubmission: segmentSubmission,
        ),
      );
    } catch (e) {
      emit(Failure(exception: e));
    }
  }
}
