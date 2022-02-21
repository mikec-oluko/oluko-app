import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/repositories/course_repository.dart';

abstract class CourseSubscriptionState {}

class CourseLoading extends CourseSubscriptionState {}

class CourseSubscriptionSuccess extends CourseSubscriptionState {
  final List<Course> values;
  CourseSubscriptionSuccess({this.values});
}

class CourseFailure extends CourseSubscriptionState {
  final dynamic exception;

  CourseFailure({this.exception});
}

class CourseSubscriptionBloc extends Cubit<CourseSubscriptionState> {
  CourseSubscriptionBloc() : super(CourseLoading());

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>> subscription;
  @override
  void dispose() {
    if (subscription != null) {
      subscription.cancel();
      subscription = null;
    }
  }

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>> getStream() {
    return subscription ??= CourseRepository().getCoursesSubscription().listen((snapshot) async {
      emit(CourseLoading());
      List<Course> courses = [];
      snapshot.docs.forEach((doc) {
        final Map<String, dynamic> content = doc.data();
        courses.add(Course.fromJson(content));
      });
      emit(CourseSubscriptionSuccess(values: courses));
    });
  }
}
