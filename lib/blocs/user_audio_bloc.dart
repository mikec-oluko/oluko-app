import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/submodels/audio.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/repositories/user_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class UserAudioState {}

class UserListLoading extends UserAudioState {}

class UserAudioSuccess extends UserAudioState {
  UserAudioSuccess({this.users});
  final List<UserResponse> users;
}

class UserAudioFailure extends UserAudioState {
  UserAudioFailure({this.exception});
  final dynamic exception;
}

class UserAudioBloc extends Cubit<UserAudioState> {
  UserAudioBloc() : super(UserListLoading());

  void getByAudios(List<Audio> audios) async {
    emit(UserListLoading());
    try {
      List<UserResponse> users = await UserRepository().getByAudios(audios);
      emit(UserAudioSuccess(users: users));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(UserAudioFailure(exception: exception));
      rethrow;
    }
  }
}
