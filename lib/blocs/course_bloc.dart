import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mvt_fitness/models/course.dart';
import 'package:mvt_fitness/models/course_category.dart';
import 'package:mvt_fitness/models/course_statistics.dart';
import 'package:mvt_fitness/repositories/course_category_repository.dart';
import 'package:mvt_fitness/repositories/course_repository.dart';
import 'package:mvt_fitness/utils/course_utils.dart';

abstract class CourseState {}

class CourseLoading extends CourseState {}

class CourseSuccess extends CourseState {
  final List<Course> values;
  final Map<CourseCategory, List<Course>> coursesByCategories;
  CourseSuccess({this.values, this.coursesByCategories});
}

class GetCourseSuccess extends CourseState {
  final Course course;
  GetCourseSuccess({this.course});
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

  void getByCategories() async {
    if (!(state is CourseSuccess)) {
      emit(CourseLoading());
    }
    try {
      List<Course> courses = await CourseRepository().getAll();
      List<CourseCategory> courseCategories =
          await CourseCategoryRepository().getAll();
      Map<CourseCategory, List<Course>> mappedCourses =
          CourseUtils.mapCoursesByCategories(courses, courseCategories);
      emit(CourseSuccess(values: courses, coursesByCategories: mappedCourses));
    } catch (e) {
      print(e.toString());
      emit(CourseFailure(exception: e));
    }
  }

  void getById(String id) async {
    if (!(state is GetCourseSuccess)) {
      emit(CourseLoading());
    }
    try {
      Course course = await CourseRepository.get(id);
      emit(GetCourseSuccess(course: course));
    } catch (e) {
      emit(CourseFailure(exception: e));
    }
  }
}
