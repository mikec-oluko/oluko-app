import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/like.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/repositories/course_user_interaction_repository.dart';
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

class CourseUserInteractionBloc extends Cubit<CourseUserInteractionState> {
  CourseUserInteractionBloc() : super(CourseInteractionLoading());

  final CourseUserInteractionRepository _courseUserInteractionRepository = CourseUserInteractionRepository();

  Future<Like> isCourseLiked({@required String courseId, @required String userId}) async {
    try {
      emit(CourseInteractionLoading());
      final Like likedCourse = await _courseUserInteractionRepository.courseIsLiked(courseId: courseId, userId: userId, isCheck: true);
      emit(CourseLikedSuccess(courseLiked: likedCourse));
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

  Future<Like> updateCourseLikeValue({@required String userId, @required String courseId}) async {
    try {
      final Like likedContent = await _courseUserInteractionRepository.updateCourseLike(userId, courseId);
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

  Future<bool> recommendCourseToFriends(
      {@required String originUserId, @required String courseRecommendedId, @required List<UserResponse> usersRecommended}) async {
    List<String> friendUsersIdCollection = [];
    if (usersRecommended.isNotEmpty) {
      friendUsersIdCollection.addAll(usersRecommended.map((friendToRecommend) => friendToRecommend.id).toList());
    }
    bool sentRecommendation = await _courseUserInteractionRepository.setCourseRecommendedByUser(
        originUserId: originUserId, courseToShareId: courseRecommendedId, usersIdsToShareCourse: friendUsersIdCollection);
    return sentRecommendation;
  }
}
