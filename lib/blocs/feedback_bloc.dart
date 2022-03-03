import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/favorite.dart';
import 'package:oluko_app/models/segment.dart';
import 'package:oluko_app/models/submodels/enrollment_segment.dart';
import 'package:oluko_app/repositories/favorite_repository.dart';
import 'package:oluko_app/repositories/segment_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class FeedbackState {}

class Loading extends FeedbackState {}

class FeedbackSuccess extends FeedbackState {
  FeedbackSuccess();
}

class Failure extends FeedbackState {
  final dynamic exception;

  Failure({this.exception});
}

class FeedbackBloc extends Cubit<FeedbackState> {
  FeedbackBloc() : super(Loading());

  void like(CourseEnrollment courseEnrollment, int classIndex, int segmentIndex, String segmentId) async {
    try {
      if (courseEnrollment.classes[classIndex].segments[segmentIndex].likes > 0 ||courseEnrollment.classes[classIndex].segments[segmentIndex].dislikes >0) {
        update(courseEnrollment, classIndex, segmentIndex, segmentId, true);
      } else {
        await SegmentRepository.addLike(courseEnrollment, classIndex, segmentIndex, segmentId);
      }
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  void dislike(CourseEnrollment courseEnrollment, int classIndex, int segmentIndex, String segmentId) async {
    try {
      if (courseEnrollment.classes[classIndex].segments[segmentIndex].dislikes > 0||courseEnrollment.classes[classIndex].segments[segmentIndex].likes >0) {
        update(courseEnrollment, classIndex, segmentIndex, segmentId, false);
      } else {
        await SegmentRepository.addDisLike(courseEnrollment, classIndex, segmentIndex, segmentId);
      }
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  void update(CourseEnrollment courseEnrollment, int classIndex, int segmentIndex, String segmentId, bool likes) async {
    try {
      await SegmentRepository.updateLikesDislikes(courseEnrollment, classIndex, segmentIndex, segmentId, likes);
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
