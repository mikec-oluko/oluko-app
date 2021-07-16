import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/course_statistics.dart';
import 'package:oluko_app/repositories/course_repository.dart';

abstract class StatisticsState {}

class StatisticsLoading extends StatisticsState {}

class StatisticsSuccess extends StatisticsState {
  final CourseStatistics courseStatistics;
  StatisticsSuccess({this.courseStatistics});
}

class StatisticsFailure extends StatisticsState {
  final Exception exception;
  StatisticsFailure({this.exception});
}

class StatisticsBloc extends Cubit<StatisticsState> {
  StatisticsBloc() : super(StatisticsLoading());

  void get(DocumentReference reference) async {
    if (!(state is StatisticsSuccess)) {
      emit(StatisticsLoading());
    }
    try {
      CourseStatistics courseStatistics =
          await CourseRepository.getStatistics(reference);
      emit(StatisticsSuccess(courseStatistics: courseStatistics));
    } catch (e) {
      print(e.toStriing());
      emit(StatisticsFailure(exception: e));
    }
  }
}
