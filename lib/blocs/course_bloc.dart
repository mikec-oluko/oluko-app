import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/assessment.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/repositories/course_repository.dart';

abstract class CourseState {}

class CourseLoading extends CourseState {}

class CourseSuccess extends CourseState {
  final List<Course> values;
  CourseSuccess({this.values});
}

class CourseFailure extends CourseState {
  final Exception exception;

  CourseFailure({this.exception});
}

class CourseBloc extends Cubit<CourseState> {
  CourseBloc() : super(CourseLoading());

  void get() async {
    if (!(state is CourseSuccess)) {
      emit(CourseLoading());
    }
    try {
      List<Course> courses = await CourseRepository().getAll();
      emit(CourseSuccess(values: courses));
    } catch (e) {
      emit(CourseFailure(exception: e));
    }
  }
}
