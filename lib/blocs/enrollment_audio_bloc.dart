import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/enrollment_audio.dart';
import 'package:oluko_app/models/submodels/audio.dart';
import 'package:oluko_app/repositories/erollment_audio_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class EnrollmentAudioState {}

class Loading extends EnrollmentAudioState {}

class GetEnrollmentAudioSuccess extends EnrollmentAudioState {
  EnrollmentAudio enrollmentAudio;
  GetEnrollmentAudioSuccess({this.enrollmentAudio});
}

class Failure extends EnrollmentAudioState {
  final dynamic exception;
  Failure({this.exception});
}

class EnrollmentAudioBloc extends Cubit<EnrollmentAudioState> {
  EnrollmentAudioBloc() : super(Loading());

  void get(String courseEnrollmentId, String classId) async {
    try {
      EnrollmentAudio enrollmentAudio = await EnrollmentAudioRepository.get(courseEnrollmentId, classId);
      List<Audio> audios = [];
      enrollmentAudio.audios.forEach( (audio) {
        if(audio.seen && !audio.deleted){
          audios.add(audio);
        }
      });
      enrollmentAudio.audios = audios;
      emit(GetEnrollmentAudioSuccess(enrollmentAudio: enrollmentAudio));
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
