import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/course_category.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/repositories/course_enrollment_repository.dart';
import 'package:oluko_app/repositories/course_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class SubscribedCourseUsersState {}

class SubscribedCourseUsersLoading extends SubscribedCourseUsersState {}

class SubscribedCourseUsersSuccess extends SubscribedCourseUsersState {
  final List<UserResponse> users;
  SubscribedCourseUsersSuccess({this.users});
}

class SubscribedCourseUsersFailure extends SubscribedCourseUsersState {
  final Exception exception;
  SubscribedCourseUsersFailure({this.exception});
}

class SubscribedCourseUsersBloc extends Cubit<SubscribedCourseUsersState> {
  SubscribedCourseUsersBloc() : super(SubscribedCourseUsersLoading());

  void get(String courseId) async {
    try {
      //Fetch enrollments for this course. And retrieve all users that are already enrolled.
      List<CourseEnrollment> courseEnrollmentList =
          await CourseEnrollmentRepository.getByCourse(courseId);

      List<DocumentSnapshot<Map<String, dynamic>>> docs = await Future.wait(
          courseEnrollmentList.map((e) => e.userReference.get()));
      List<UserResponse> userList = docs.map((e) {
        var data = e.data();
        return data != null ? UserResponse.fromJson(e.data()) : null;
      }).toList();

      userList.removeWhere((element) => element == null);

      emit(SubscribedCourseUsersSuccess(users: userList));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(SubscribedCourseUsersFailure(exception: exception));
    }
  }
}
