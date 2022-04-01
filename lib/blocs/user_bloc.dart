import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/repositories/user_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class UserState {}

class UserLoading extends UserState {}

class UserListSuccess extends UserState {
    UserListSuccess({this.users});
  final List<UserResponse> users;
}

class UserFailure extends UserState {
   UserFailure({this.exception});
  final dynamic exception;
}

class UserBloc extends Cubit<UserState> {
  UserBloc() : super(UserLoading());

  void saveToken(String userId, String token) {
    try {
      UserRepository().saveToken(userId, token);
    } catch (exception, stackTrace) {
      Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(UserFailure(exception: exception));
      rethrow;
    }
  }
}
