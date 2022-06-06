import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/like.dart';
import 'package:oluko_app/repositories/course_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class CourseUserInteractionState {}

class CourseInteractionLoading extends CourseUserInteractionState {}

class CourseRecommendedSuccess extends CourseUserInteractionState {
  final bool recommendedSuccess;
  CourseRecommendedSuccess({this.recommendedSuccess});
}

class CourseLikedSuccess extends CourseUserInteractionState {
  final Like courseLiked;
  CourseLikedSuccess({this.courseLiked});
}

class CourseInteractionFailure extends CourseUserInteractionState {
  final dynamic exception;
  CourseInteractionFailure({this.exception});
}

class CourseUserIteractionBloc extends Cubit<CourseUserInteractionState> {
  CourseUserIteractionBloc() : super(CourseInteractionLoading());

  final CourseRepository _courseRepository = CourseRepository();

  Future<Like> isCourseLiked({@required String courseId, @required String userId}) async {
    try {
      emit(CourseInteractionLoading());
      final Like likedCourse = await _courseRepository.courseIsLiked(courseId, userId);
      return likedCourse;
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(CourseInteractionFailure(exception: exception));
      rethrow;
    }
  }

  Future<Like> markCourseAsLiked({@required String userId, @required String courseId}) async {
    try {
      final Like likedContent = await _courseRepository.markCourseAsLiked(userId, courseId);
      emit(CourseLikedSuccess(courseLiked: likedContent));
      return likedContent;
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(CourseInteractionFailure(exception: exception));
      rethrow;
    }
  }
}
