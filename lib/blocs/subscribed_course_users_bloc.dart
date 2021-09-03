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

      List<UserResponse> uniqueUserList = [];
      List<String> uniqueUserIds = [];
      List<UserResponse> favoriteUserList = [];
      List<UserResponse> userListToShow = [];
      if (courseEnrollmentList != null) {
        //User list for all subscribers of this course.
        List<UserResponse> usersSubscribedToCourse = await Future.wait(
            courseEnrollmentList
                .map((e) => UserRepository().getById(e.userReference.id)));
        //Remove enrollments without user
        usersSubscribedToCourse.removeWhere((element) => element == null);

        usersSubscribedToCourse.forEach((userSubscribed) {
          if (uniqueUserIds.indexOf(userSubscribed.id) == -1) {
            uniqueUserList.add(userSubscribed);
            uniqueUserIds.add(userSubscribed.id);
          }
        });

        Friend friendData =
            await FriendRepository.getUserFriendsByUserId(userId);
        List<FriendModel> friends = friendData.friends;

        userListToShow = List.from(uniqueUserList);

        friends.forEach((friend) {
          if (friend.isFavorite) {
            num index = userListToShow
                .map((user) => user.id)
                .toList()
                .indexOf(friend.id);
            favoriteUserList.add(userListToShow[index]);
          }
        });
      }

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
