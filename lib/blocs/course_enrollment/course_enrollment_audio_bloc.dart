import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/enrollment_audio.dart';
import 'package:oluko_app/models/submodels/audio.dart';
import 'package:oluko_app/repositories/erollment_audio_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class CourseEnrollmentAudioState {}

class Loading extends CourseEnrollmentAudioState {}

class Failure extends CourseEnrollmentAudioState {
  final dynamic exception;
  Failure({this.exception});
}

class ClassAudioDeleteSuccess extends CourseEnrollmentAudioState {
  final List<Audio> audios;
  ClassAudioDeleteSuccess({this.audios});
}

class CourseEnrollmentAudioBloc extends Cubit<CourseEnrollmentAudioState> {
  CourseEnrollmentAudioBloc() : super(Loading());

  void markAudioAsDeleted(EnrollmentAudio enrollmentAudio, List<Audio> audiosUpdated, List<Audio> audios) async {
    try {
      await EnrollmentAudioRepository.markAudioAsDeleted(enrollmentAudio, audiosUpdated);
      emit(ClassAudioDeleteSuccess(audios: audios));
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
