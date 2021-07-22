import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/assessment.dart';
import 'package:oluko_app/models/course_category.dart';
import 'package:oluko_app/repositories/course_category_repository.dart';

abstract class CourseCategoryState {}

class CourseCategoryLoading extends CourseCategoryState {}

class CourseCategorySuccess extends CourseCategoryState {
  final List<CourseCategory> values;
  CourseCategorySuccess({this.values});
}

class CourseCategoryFailure extends CourseCategoryState {
  final Exception exception;

  CourseCategoryFailure({this.exception});
}

class CourseCategoryBloc extends Cubit<CourseCategoryState> {
  CourseCategoryBloc() : super(CourseCategoryLoading());

  void get() async {
    if (!(state is CourseCategorySuccess)) {
      emit(CourseCategoryLoading());
    }
    try {
      List<CourseCategory> courses = await CourseCategoryRepository().getAll();
      emit(CourseCategorySuccess(values: courses));
    } catch (e) {
      emit(CourseCategoryFailure(exception: e));
    }
  }
}
