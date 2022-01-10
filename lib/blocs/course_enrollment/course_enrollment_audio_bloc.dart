import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/enrollment_audio.dart';
import 'package:oluko_app/models/submodels/audio.dart';
import 'package:oluko_app/repositories/erollment_audio_repository.dart';
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

  void markAudioAsDeleted(EnrollmentAudio enrollmentAudio, List<Audio> audios, String classId) async {
    try {
      await EnrollmentAudioRepository.markAudioAsDeleted(enrollmentAudio, audios, classId);
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
