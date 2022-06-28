import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/course_category.dart';
import 'package:oluko_app/models/like.dart';
import 'package:oluko_app/models/recommendation.dart';
import 'package:oluko_app/models/submodels/course_category_item.dart';
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

class CourseLikedListSuccess extends CourseUserInteractionState {
  final CourseCategory myLikedCourses;
  CourseLikedListSuccess({this.myLikedCourses});
}

class CoursesRecommendedByFriendsSuccess extends CourseUserInteractionState {
  final List<Recommendation> recommendedCourses;
  CoursesRecommendedByFriendsSuccess({this.recommendedCourses});
}

class CourseInteractionFailure extends CourseUserInteractionState {
  final dynamic exception;
  CourseInteractionFailure({this.exception});
}

class CourseUserIteractionBloc extends Cubit<CourseUserInteractionState> {
  CourseUserIteractionBloc() : super(CourseInteractionLoading());

  final CourseUserInteractionRepository _courseUserInteractionRepository = CourseUserInteractionRepository();
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>> _likeSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>> _CourseRecommendedSubscription;

  @override
  void dispose() {
    _likeSubscription != null
        ? _likeSubscription.cancel()
        : _CourseRecommendedSubscription != null
            ? _CourseRecommendedSubscription.cancel()
            : null;
  }

  Future<Like> isCourseLiked({@required String courseId, @required String userId}) async {
    try {
      emit(CourseInteractionLoading());
      final Like likedCourse = await _courseUserInteractionRepository.courseIsLiked(courseId: courseId, userId: userId);
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

  recommendCourseToFriends(
      {@required String originUserId, @required String courseRecommendedId, @required List<UserResponse> usersRecommended}) async {
    List<String> friendUsersIdCollection = [];
    if (usersRecommended.isNotEmpty) {
      friendUsersIdCollection.addAll(usersRecommended.map((friendToRecommend) => friendToRecommend.id).toList());
    }
    bool sentRecommendation = await _courseUserInteractionRepository.setCourseRecommendedByUser(
        originUserId: originUserId, courseToShareId: courseRecommendedId, usersIdsToShareCourse: friendUsersIdCollection);
    return sentRecommendation;
  }

  Future<StreamSubscription<QuerySnapshot<Map<String, dynamic>>>> getStreamOfCoursesRecommendedByFriends({@required String userId}) async {
    try {
      return _CourseRecommendedSubscription ??=
          _courseUserInteractionRepository.getRecommendedCoursesByFriends(userId: userId).listen((snapshot) {
        List<Recommendation> _recommendedCourses = [];
        //   emit(Loading());
        if (snapshot.docs.isNotEmpty) {
          snapshot.docs.forEach((courseRecommended) {
            final Map<String, dynamic> _courseRecommended = courseRecommended.data();
            _recommendedCourses.add(Recommendation.fromJson(_courseRecommended));
          });
        }
        emit(CoursesRecommendedByFriendsSuccess(recommendedCourses: _recommendedCourses));
      });
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(CourseInteractionFailure(exception: exception));
      rethrow;
    }
  }

  Future<StreamSubscription<QuerySnapshot<Map<String, dynamic>>>> getStreamOfLikedCourses({@required String userId}) async {
    try {
      return _likeSubscription ??= _courseUserInteractionRepository.getLikedCoursesSubscription(userId: userId).listen((snapshot) {
        CourseCategory _likeCourseCategory;
        List<Like> _likedCourses = [];
        List<CourseCategoryItem> _coursesLikedList = [];
        //   emit(Loading());
        if (snapshot.docs.isNotEmpty) {
          snapshot.docs.forEach((courseLiked) {
            final Map<String, dynamic> _likedCourse = courseLiked.data();
            _likedCourses.add(Like.fromJson(_likedCourse));
          });

          _likedCourses.forEach((courseLiked) {
            // _coursesLikedList
            if (courseLiked.isActive) {
              CourseCategoryItem _courseLikedItem = CourseCategoryItem(id: courseLiked.entityId, reference: courseLiked.entityReference);
              if (_coursesLikedList.isNotEmpty) {
                if (_coursesLikedList.where((likedCourse) => likedCourse.id == _courseLikedItem.id).isEmpty) {
                  _coursesLikedList.add(_courseLikedItem);
                }
              } else {
                _coursesLikedList.add(_courseLikedItem);
              }
            }
          });
          _likeCourseCategory = CourseCategory(name: 'Favorite Courses', courses: _coursesLikedList);
          print(_likeCourseCategory);
        }
        emit(CourseLikedListSuccess(myLikedCourses: _likeCourseCategory));
      });
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
