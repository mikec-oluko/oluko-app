import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/friend.dart';
import 'package:oluko_app/models/friend_model.dart';
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
  final Exception exception;
  SubscribedCourseUsersFailure({this.exception});
}

class SubscribedCourseUsersBloc extends Cubit<SubscribedCourseUsersState> {
  SubscribedCourseUsersBloc() : super(SubscribedCourseUsersLoading());

  void get(String courseId, String userId) async {
    try {
      //Fetch enrollments for this course. And retrieve all users that are already enrolled.
      List<CourseEnrollment> courseEnrollmentList =
          await CourseEnrollmentRepository.getByCourse(courseId);

      List<UserResponse> userList = await Future.wait(courseEnrollmentList
          .map((e) => UserRepository().getById(e.userReference.id)));

      userList.removeWhere((element) => element == null);

      List<UserResponse> uniqueUserList = [];
      userList.forEach((element) {
        if (uniqueUserList
                .map((e) => e.username)
                .toList()
                .indexOf(element.username) ==
            -1) {
          uniqueUserList.add(element);
        }
      });

      Friend friendData = await FriendRepository.getUserFriendsByUserId(userId);
      List<FriendModel> friends = friendData.friends;

      List<UserResponse> favoriteUserList = [];
      List<UserResponse> userListToShow = List.from(uniqueUserList);

      uniqueUserList.forEach((user) => {
            friends.forEach((friend) {
              if (friend.id == user.id && friend.isFavorite) {
                userListToShow
                    .removeWhere((element) => element.id == friend.id);
                favoriteUserList.add(user);
              }
            })
          });

      emit(SubscribedCourseUsersSuccess(
          users: userListToShow, favoriteUsers: favoriteUserList));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(SubscribedCourseUsersFailure(exception: exception));
    }
  }
}
