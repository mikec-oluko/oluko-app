import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/repositories/course_enrollment_repository.dart';

abstract class CourseEnrollmentListStreamState {}

class Loading extends CourseEnrollmentListStreamState {}

class Failure extends CourseEnrollmentListStreamState {
  final dynamic exception;
  Failure({this.exception});
}

class CourseEnrollmentsByUserStreamSuccess extends CourseEnrollmentListStreamState {
  final List<CourseEnrollment> courseEnrollments;
  CourseEnrollmentsByUserStreamSuccess({this.courseEnrollments});
}

class CourseEnrollmentsByUserUpdate extends CourseEnrollmentListStreamState {
  final List<CourseEnrollment> courseEnrollments;
  CourseEnrollmentsByUserUpdate({this.courseEnrollments});
}

class CourseEnrollmentListStreamBloc extends Cubit<CourseEnrollmentListStreamState> {
  CourseEnrollmentListStreamBloc() : super(Loading());

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>> subscription;
  @override
  void dispose() {
    if (subscription != null) {
      subscription.cancel();
      subscription = null;
    }
  }

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>> getStream(String userId) {
    return subscription ??= CourseEnrollmentRepository.getUserCourseEnrollmentsSubscription(userId).listen((snapshot) async {
      emit(Loading());
      List<CourseEnrollment> courseEnrollments = [];
      snapshot.docs.forEach((doc) {
        final Map<String, dynamic> content = doc.data();
        courseEnrollments.add(CourseEnrollment.fromJson(content));
      });
      emit(CourseEnrollmentsByUserStreamSuccess(
          courseEnrollments:
              courseEnrollments.where((element) => element.completion < 1).where((element) => element.isUnenrolled != true).toList()));
    });
  }
}
