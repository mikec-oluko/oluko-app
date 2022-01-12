import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/friend.dart';
import 'package:oluko_app/models/submodels/friend_model.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/repositories/course_enrollment_repository.dart';
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
    try {
      //Fetch enrollments for this course. And retrieve all users that are already enrolled.
      List<CourseEnrollment> courseEnrollmentList = await CourseEnrollmentRepository.getByCourse(courseId, userId);
      List<CourseEnrollment> enrolledList =
          courseEnrollmentList.where((element) => element.isUnenrolled != true).where((element) => element.completion < 1).toList();
      List<UserResponse> uniqueUserList = [];
      List<UserResponse> favoriteUserList = [];
      List<UserResponse> userListToShow = [];
      if (courseEnrollmentList != null) {
        //User list for all subscribers of this course.
        List<UserResponse> usersSubscribedToCourse =
            await Future.wait(enrolledList.map((e) => UserRepository().getById(e.userReference.id)));
        //Remove enrollments without user
        usersSubscribedToCourse.removeWhere((element) => element == null);

        usersSubscribedToCourse.forEach((userSubscribed) {
          if (!uniqueUserList.any((user) => user.id == userSubscribed.id)) {
            uniqueUserList.add(userSubscribed);
          }
        });

        Friend friendData = await FriendRepository.getUserFriendsByUserId(userId);
        List<FriendModel> friends = friendData == null ? null : friendData.friends;

        userListToShow = List.from(uniqueUserList);
        if (friends != null) {
          friends.forEach((friend) {
            if (friend.isFavorite) {
              final int index = userListToShow.indexWhere((user) => user.id == friend.id);
              if (index != -1) {
                favoriteUserList.add(userListToShow[index]);
                userListToShow.removeAt(index);
              }
            }
          });
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
}
