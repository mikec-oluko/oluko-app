import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/challenge.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/repositories/course_enrollment_repository.dart';

abstract class CourseEnrollmentState {}

class Loading extends CourseEnrollmentState {}

class CreateEnrollmentSuccess extends CourseEnrollmentState {
  CourseEnrollment courseEnrollment;
  CreateEnrollmentSuccess({this.courseEnrollment});
}

class GetEnrollmentSuccess extends CourseEnrollmentState {
  CourseEnrollment courseEnrollment;
  GetEnrollmentSuccess({this.courseEnrollment});
}

class Failure extends CourseEnrollmentState {
  final Exception exception;

  Failure({this.exception});
}

class CourseEnrollmentGetChallenge extends CourseEnrollmentState {
  final List<Challenge> challenges;

  CourseEnrollmentGetChallenge({this.challenges});
}

class CourseEnrollmentBloc extends Cubit<CourseEnrollmentState> {
  CourseEnrollmentBloc() : super(Loading());

  void create(User user, Course course) async {
    try {
      CourseEnrollment courseEnrollment =
          await CourseEnrollmentRepository.create(user, course);
      emit(GetEnrollmentSuccess(courseEnrollment: courseEnrollment));
    } catch (e) {
      emit(Failure(exception: e));
    }
  }

  void get(User user, Course course) async {
    try {
      CourseEnrollment courseEnrollment =
          await CourseEnrollmentRepository.get(course, user);
      emit(GetEnrollmentSuccess(courseEnrollment: courseEnrollment));
    } catch (e) {
      emit(Failure(exception: e));
    }
  }

  void getChallengesForUser(String userId) async {
    try {
      List<Challenge> courseEnrollmentsChallenges =
          await CourseEnrollmentRepository().getUserChallenges(userId);

      emit(CourseEnrollmentGetChallenge(
          challenges: courseEnrollmentsChallenges));
    } catch (e) {
      emit(Failure(exception: e));
    }
  }
}
