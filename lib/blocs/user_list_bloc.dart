import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/repositories/user_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class UserListState {}

class UserListLoading extends UserListState {}

class UserListSuccess extends UserListState {
    UserListSuccess({this.users});
  final List<UserResponse> users;
}

class UserListFailure extends UserListState {
   UserListFailure({this.exception});
  final dynamic exception;
}

class UserListBloc extends Cubit<UserListState> {
  UserListBloc() : super(UserListLoading());

  void get() async {
    try {
      List<UserResponse> result = await UserRepository().getAll();
      emit(UserListSuccess(users: result));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(UserListFailure(exception: exception));
      rethrow;
    }
  }
}
