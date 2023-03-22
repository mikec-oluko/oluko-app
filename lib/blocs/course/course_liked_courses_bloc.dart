import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/course_category.dart';
import 'package:oluko_app/models/like.dart';
import 'package:oluko_app/models/submodels/course_category_item.dart';
import 'package:oluko_app/repositories/course_user_interaction_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class LikedCourseState {}

class LikedCoursesLoading extends LikedCourseState {}

class LikedCoursesDispose extends LikedCourseState {}

class CourseLikedListSuccess extends LikedCourseState {
  final CourseCategory myLikedCourses;
  CourseLikedListSuccess({this.myLikedCourses});
}

class LikedCourseFailure extends LikedCourseState {
  final dynamic exception;
  LikedCourseFailure({this.exception});
}

class LikedCoursesBloc extends Cubit<LikedCourseState> {
  LikedCoursesBloc() : super(LikedCoursesLoading());

  final CourseUserInteractionRepository _courseUserInteractionRepository = CourseUserInteractionRepository();
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>> _likeSubscription;

  @override
  void dispose() {
    if (_likeSubscription != null) {
      _likeSubscription.cancel();
      _likeSubscription = null;
    }
    emit(LikedCoursesDispose());
  }

  Future<StreamSubscription<QuerySnapshot<Map<String, dynamic>>>> getStreamOfLikedCourses({@required String userId}) async {
    const String _myListTitle = 'My List';
    try {
      return _likeSubscription ??= _courseUserInteractionRepository.getLikedCoursesSubscription(userId: userId).listen((snapshot) {
        CourseCategory _likeCourseCategory;
        List<Like> _likedCourses = [];
        List<CourseCategoryItem> _coursesLikedList = [];
        emit(LikedCoursesLoading());
        if (snapshot.docs.isNotEmpty) {
          snapshot.docs.forEach((courseLiked) {
            final Map<String, dynamic> _likedCourse = courseLiked.data();

            _likedCourses.add(Like.fromJson(_likedCourse));
          });

          _likedCourses.forEach((courseLiked) {
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
          _likeCourseCategory = CourseCategory(name: _myListTitle, courses: _coursesLikedList);
        }
        emit(CourseLikedListSuccess(myLikedCourses: _likeCourseCategory));
      });
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(LikedCourseFailure(exception: exception));
      rethrow;
    }
  }
}
