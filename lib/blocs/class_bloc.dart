import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/class.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/repositories/class_reopository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class ClassState {}

class Loading extends ClassState {}

class GetSuccess extends ClassState {
  List<Class> classes;
  GetSuccess({this.classes});
}

class GetByIdSuccess extends ClassState {
  Class classObj;
  GetByIdSuccess({this.classObj});
}

class Failure extends ClassState {
  final dynamic exception;

  Failure({this.exception});
}

class ClassBloc extends Cubit<ClassState> {
  ClassBloc() : super(Loading());

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>> subscription;
  @override
  void dispose() {
    if (subscription != null) {
      subscription.cancel();
      subscription = null;
    }
  }

  void getAll(Course course) async {
    emit(Loading());
    try {
      List<Class> classes = await ClassRepository.getAll(course);
      emit(GetSuccess(classes: classes));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(Failure(exception: exception));
      rethrow;
    }
  }

  void get(String id) async {
    emit(Loading());
    try {
      Class classObj = await ClassRepository.get(id);
      emit(GetByIdSuccess(classObj: classObj));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(Failure(exception: exception));
      rethrow;
    }
  }

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>> getStream() {
    subscription ??= ClassRepository.getClassesSubscription().listen((snapshot) async {
      List<Class> classes = [];
      snapshot.docs.forEach((doc) {
        final Map<String, dynamic> content = doc.data();
        classes.add(Class.fromJson(content));
      });
      emit(GetSuccess(classes: classes));
    });
    return subscription;
  }
}
