import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/submodels/audio.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/repositories/user_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class CoachAudioState {}

class CoachUserLoading extends CoachAudioState {}

class CoachesByAudiosSuccess extends CoachAudioState {
  final List<UserResponse> coaches;
  CoachesByAudiosSuccess({this.coaches});
}

class CoachAudioFailure extends CoachAudioState {
  final dynamic exception;
  CoachAudioFailure({this.exception});
}

class CoachAudioBloc extends Cubit<CoachAudioState> {
  CoachAudioBloc() : super(CoachUserLoading());

  void getByAudios(List<Audio> audios) async {
    emit(CoachUserLoading());
    try {
      List<UserResponse> coaches = await UserRepository().getByAudios(audios);
      emit(CoachesByAudiosSuccess(coaches: coaches));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(CoachAudioFailure(exception: exception));
      rethrow;
    }
  }
}
