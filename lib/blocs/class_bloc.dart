import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/class.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/repositories/class_reopoistory.dart';

abstract class ClassState {}

class Loading extends ClassState {}

class GetSuccess extends ClassState {
  List<Class> classes;
  GetSuccess({this.classes});
}

class Failure extends ClassState {
  final Exception exception;

  Failure({this.exception});
}

class ClassBloc extends Cubit<ClassState> {
  ClassBloc() : super(Loading());

  void getAll(Course course) async {
    try {
      List<Class> classes = await ClassRepository.getAll(course);
      emit(GetSuccess(classes: classes));
    } catch (e) {
      print(e.toString());
      emit(Failure(exception: e));
    }
  }
}
