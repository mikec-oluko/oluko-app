import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/coach_request.dart';
import 'package:oluko_app/models/submodels/audio.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/repositories/coach_request_repository.dart';
import 'package:oluko_app/repositories/user_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class CoachUserState {}

class CoachUserLoading extends CoachUserState {}

class CoachUserSuccess extends CoachUserState {
  final UserResponse coach;
  CoachUserSuccess({this.coach});
}

class CoachesByAudiosSuccess extends CoachUserState {
  final List<UserResponse> coaches;
  CoachesByAudiosSuccess({this.coaches});
}

class CoachUserFailure extends CoachUserState {
  final dynamic exception;
  CoachUserFailure({this.exception});
}

class CoachUserBloc extends Cubit<CoachUserState> {
  CoachUserBloc() : super(CoachUserLoading());

  void get(String userId) async {
    emit(CoachUserLoading());
    try {
      UserResponse coach = await UserRepository().getById(userId);
      emit(CoachUserSuccess(coach: coach));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(CoachUserFailure(exception: exception));
      rethrow;
    }
  }

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
      emit(CoachUserFailure(exception: exception));
      rethrow;
    }
  }
}
