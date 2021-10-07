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
}
