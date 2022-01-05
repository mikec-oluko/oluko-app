import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/submodels/audio.dart';
import 'package:oluko_app/repositories/course_enrollment_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class CourseEnrollmentListState {}

class Loading extends CourseEnrollmentListState {}

class Failure extends CourseEnrollmentListState {
  final dynamic exception;
  Failure({this.exception});
}

class ClassAudioDeleteSuccess extends CourseEnrollmentListState {}

class CourseEnrollmentAudioBloc extends Cubit<CourseEnrollmentListState> {
  CourseEnrollmentAudioBloc() : super(Loading());

  void markAudioAsDeleted(CourseEnrollment courseEnrollment, List<Audio> audios) async {
    try {
      await CourseEnrollmentRepository.markAudioAsDeleted(courseEnrollment, audios);
      emit(ClassAudioDeleteSuccess());
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
