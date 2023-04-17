import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/assessment.dart';
import 'package:oluko_app/models/course_category.dart';
import 'package:oluko_app/repositories/course_category_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class CourseCategoryState {}

class CourseCategoryLoading extends CourseCategoryState {}

class CourseCategorySuccess extends CourseCategoryState {
  final List<CourseCategory> values;
  CourseCategorySuccess({this.values});
}

class CourseCategorySubscriptionSuccess extends CourseCategoryState {
  final List<CourseCategory> values;
  CourseCategorySubscriptionSuccess({this.values});
}

class CourseCategoryFailure extends CourseCategoryState {
  final dynamic exception;

  CourseCategoryFailure({this.exception});
}

class CourseCategoryBloc extends Cubit<CourseCategoryState> {
  CourseCategoryBloc() : super(CourseCategoryLoading());

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>> subscription;
  @override
  void dispose() {
    if (subscription != null) {
      subscription.cancel();
      subscription = null;
    }
  }

  void get() async {
    if (!(state is CourseCategorySuccess)) {
      emit(CourseCategoryLoading());
    }
    try {
      List<CourseCategory> courses = await CourseCategoryRepository().getAll();
      emit(CourseCategorySuccess(values: courses));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(CourseCategoryFailure(exception: exception));
      rethrow;
    }
  }

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>> getStream() {
    return subscription ??= CourseCategoryRepository().getCategoriesSubscription().listen((snapshot) async {
      List<CourseCategory> courseCategories = [];
      try {
        emit(CourseCategoryLoading());
        snapshot.docs.forEach((doc) {
          final Map<String, dynamic> content = doc.data();
          courseCategories.add(CourseCategory.fromJson(content));
        });
        courseCategories.sort((a, b) => a.index.compareTo(b.index));
        emit(CourseCategorySubscriptionSuccess(values: courseCategories));
      } catch (exception, stackTrace) {
        await Sentry.captureException(
          exception,
          stackTrace: stackTrace,
        );
        emit(CourseCategoryFailure(exception: exception));
      }
    }, onError: (dynamic error, StackTrace stackTrace) async {
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
      );
      emit(CourseCategoryFailure(exception: error));
    });
  }
}
