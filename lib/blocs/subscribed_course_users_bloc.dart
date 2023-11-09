import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/course_statistics.dart';
import 'package:oluko_app/models/friend.dart';
import 'package:oluko_app/models/submodels/friend_model.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/repositories/course_enrollment_repository.dart';
import 'package:oluko_app/repositories/course_repository.dart';
import 'package:oluko_app/repositories/friend_repository.dart';
import 'package:oluko_app/repositories/user_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class SubscribedCourseUsersState {}

class SubscribedCourseUsersLoading extends SubscribedCourseUsersState {}

class SubscribedCourseUsersSuccess extends SubscribedCourseUsersState {
  final List<UserResponse> users;
  final List<UserResponse> favoriteUsers;
  SubscribedCourseUsersSuccess({this.users, this.favoriteUsers});
}

class SubscribedCourseUsersFailure extends SubscribedCourseUsersState {
  final dynamic exception;
  SubscribedCourseUsersFailure({this.exception});
}

class SubscribedCourseUsersBloc extends Cubit<SubscribedCourseUsersState> {
  SubscribedCourseUsersBloc() : super(SubscribedCourseUsersLoading());

  void get(String courseId, String userId) async {
    emit(SubscribedCourseUsersLoading());
    try {
      List<UserResponse> usersByCourse = await CourseRepository.getUsersByCourseId(courseId, userId);

      if (usersByCourse == null || usersByCourse.isEmpty) {
        emit(SubscribedCourseUsersSuccess(users: [], favoriteUsers: []));
        return;
      }

      final Set<String> uniqueUserIds = {};
      final List<UserResponse> favoriteUserList = [];
      final List<UserResponse> userListToShow = [];

      for (int i = 0; i < usersByCourse.length; i++) {
        final userSubscribed = usersByCourse[i];
        if (uniqueUserIds.add(userSubscribed.id)) {
          userListToShow.add(userSubscribed);
        }
      }
      final Friend friendData = await FriendRepository.getUserFriendsByUserId(userId);
      final List<String> friendIds = friendData?.friends?.map((friend) => friend.id)?.toList() ?? [];

      for (int i = userListToShow.length - 1; i >= 0; i--) {
        if (friendIds.contains(userListToShow[i].id)) {
          favoriteUserList.add(userListToShow[i]);
          userListToShow.removeAt(i);
        }
      }
      emit(SubscribedCourseUsersSuccess(users: userListToShow, favoriteUsers: favoriteUserList));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(SubscribedCourseUsersFailure(exception: exception));
      rethrow;
    }
  }

  void getEnrolled(String courseId, String userId) async {
    try {
      emit(SubscribedCourseUsersLoading());
      List<UserResponse> returnList = [];
      List<CourseEnrollment> courseEnrollmentList = await CourseEnrollmentRepository.getByActiveCourse(courseId, userId);
      courseEnrollmentList = courseEnrollmentList.where((element) => element.completion < 1).toList();
      if (courseEnrollmentList != null) {
        final List<String> enrolledUserId = courseEnrollmentList.map((e) => e.createdBy).toList();
        returnList = await UserRepository().getAll();
        returnList = returnList.where((element) => enrolledUserId.indexOf(element.id) != -1 && element.id != userId).toList();
      }
      emit(SubscribedCourseUsersSuccess(users: returnList));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(SubscribedCourseUsersFailure(exception: exception));
      rethrow;
    }
  }

  void getCourseStatisticsUsers(String courseId, String userId) async {
    try {
      emit(SubscribedCourseUsersLoading());
      final CourseStatistics courseStatistic = await CourseRepository.getStatisticsById(courseId);
      final List<UserResponse> userList = await Future.wait(
        courseStatistic.activeUsers.map((String id) {
          return UserRepository().getById(id);
        }),
      );
      userList.removeWhere((element) => element == null || element.id == userId);
      emit(SubscribedCourseUsersSuccess(users: userList));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(SubscribedCourseUsersFailure(exception: exception));
      rethrow;
    }
  }
}
