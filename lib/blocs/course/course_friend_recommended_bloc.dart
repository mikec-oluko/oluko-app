import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/recommendation.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/repositories/course_user_interaction_repository.dart';
import 'package:oluko_app/repositories/user_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class CourseRecommendedByFriendState {}

class CourseRecommendedByFriendLoading extends CourseRecommendedByFriendState {}

class CourseRecommendedByFriendSuccess extends CourseRecommendedByFriendState {
  final List<Map<String, List<UserResponse>>> recommendedCourses;
  CourseRecommendedByFriendSuccess({this.recommendedCourses});
}

class CourseRecommendedByFriendFailure extends CourseRecommendedByFriendState {
  final dynamic exception;
  CourseRecommendedByFriendFailure({this.exception});
}

class CourseRecommendedByFriendBloc extends Cubit<CourseRecommendedByFriendState> {
  CourseRecommendedByFriendBloc() : super(CourseRecommendedByFriendLoading());

  final CourseUserInteractionRepository _courseUserInteractionRepository = CourseUserInteractionRepository();
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>> _courseRecommendedSubscription;

  @override
  void dispose() {
    if (_courseRecommendedSubscription != null) {
      _courseRecommendedSubscription.cancel();
      _courseRecommendedSubscription = null;
    }
  }

  Future<StreamSubscription<QuerySnapshot<Map<String, dynamic>>>> getStreamOfCoursesRecommendedByFriends({@required String userId}) async {
    List<Map<String, List<UserResponse>>> _coursesRecommendedAndUsersList = [];
    Map<String, List<UserResponse>> _courseWithUsersRecommended;
    List<Recommendation> _recommendedCourses = [];
    List<UserResponse> _friendUsers = [];
    try {
      return _courseRecommendedSubscription ??=
          _courseUserInteractionRepository.getRecommendedCoursesByFriends(userId: userId).listen((snapshot) async {
        emit(CourseRecommendedByFriendLoading());

        if (snapshot.docs.isNotEmpty) {
          snapshot.docs.forEach((courseRecommended) {
            final Map<String, dynamic> _courseRecommended = courseRecommended.data();
            _recommendedCourses.add(Recommendation.fromJson(_courseRecommended));
          });

          List<String> _friendsIds = _recommendedCourses.map((e) => e.originUserId).toList().toSet().toList();

          List<UserResponse> _friendsUsers = await Future.wait(_friendsIds.map((String userId) async {
            return UserRepository().getById(userId);
          }).toList());

          _recommendedCourses.forEach((courseRecommended) {
            _courseWithUsersRecommended = {
              courseRecommended.entityId: [_friendsUsers.where((friendProfile) => friendProfile.id == courseRecommended.originUserId).first]
            };
            if (_coursesRecommendedAndUsersList.isEmpty) {
              _coursesRecommendedAndUsersList.add(_courseWithUsersRecommended);
            } else {
              if (_coursesRecommendedAndUsersList.where((element) => element.keys.first == courseRecommended.entityId).toList().isEmpty) {
                _coursesRecommendedAndUsersList.add(_courseWithUsersRecommended);
              } else {
                final _existingRecommendation =
                    _coursesRecommendedAndUsersList.where((element) => element.keys.first == courseRecommended.entityId).toList().first;
                final indexOfExistingRecommendation = _coursesRecommendedAndUsersList.indexOf(_existingRecommendation);
                _coursesRecommendedAndUsersList[indexOfExistingRecommendation]
                    .values
                    .first
                    .add(_friendsUsers.where((element) => element.id == courseRecommended.originUserId).first);
              }
            }
          });
        }

        emit(CourseRecommendedByFriendSuccess(recommendedCourses: _coursesRecommendedAndUsersList));
      });
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(CourseRecommendedByFriendFailure(exception: exception));
      rethrow;
    }
  }
}
