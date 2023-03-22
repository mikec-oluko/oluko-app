import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/repositories/course_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class CourseSubscriptionState {}

class CourseLoading extends CourseSubscriptionState {}

class CourseDisposeState extends CourseSubscriptionState {}

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
    emit(CourseDisposeState());
  }

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>> getStream() {
    List<Course> courses = [];
    return subscription ??= CourseRepository().getCoursesSubscription().listen((snapshot) async {
      try {
        emit(CourseLoading());
        snapshot.docs.forEach((doc) {
          final Map<String, dynamic> content = doc.data();
          Course c = Course.fromJson(content);
          final index = courses.indexWhere((element) => element.id == c.id);
          if (index == -1) {
            courses.add(c);
          } else {
            print("DUPLICATED COURSE");
          }
        });
        emit(CourseSubscriptionSuccess(values: courses));
      } catch (exception, stackTrace) {
        await Sentry.captureException(
          exception,
          stackTrace: stackTrace,
        );
        emit(CourseFailure(exception: exception));
      }
    }, onError: (dynamic error, StackTrace stackTrace) async {
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
      );
      emit(CourseFailure(exception: error));
    });
  }
}
