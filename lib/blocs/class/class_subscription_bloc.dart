import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/class.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/repositories/class_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class ClassSubscriptionState {}

class Loading extends ClassSubscriptionState {}

class ClassSubscriptionSuccess extends ClassSubscriptionState {
  List<Class> classes;
  ClassSubscriptionSuccess({this.classes});
}

class Failure extends ClassSubscriptionState {
  final dynamic exception;

  Failure({this.exception});
}

class ClassSubscriptionBloc extends Cubit<ClassSubscriptionState> {
  ClassSubscriptionBloc() : super(Loading());

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>> subscription;
  @override
  void dispose() {
    if (subscription != null) {
      subscription.cancel();
      subscription = null;
    }
  }

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>> getStream() {
    return subscription ??= ClassRepository.getClassesSubscription().listen((snapshot) async {
      try {
        List<Class> classes = [];
        snapshot.docs.forEach((doc) {
          final Map<String, dynamic> content = doc.data();
          classes.add(Class.fromJson(content));
        });
        emit(ClassSubscriptionSuccess(classes: classes));
      } catch (exception, stackTrace) {
        await Sentry.captureException(
          exception,
          stackTrace: stackTrace,
        );
        emit(Failure(exception: exception));
      }
    });
  }
}
