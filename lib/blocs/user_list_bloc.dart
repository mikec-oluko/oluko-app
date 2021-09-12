import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/course_statistics.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/repositories/course_repository.dart';
import 'package:oluko_app/repositories/user_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class UserListState {}

class UserListLoading extends UserListState {}

class UserListSuccess extends UserListState {
  final List<UserResponse> users;
  UserListSuccess({this.users});
}

class UserListFailure extends UserListState {
  final Exception exception;
  UserListFailure({this.exception});
}

class UserListBloc extends Cubit<UserListState> {
  UserListBloc() : super(UserListLoading());

  void get() async {
    try {
      List<UserResponse> result = await UserRepository().getAll();
      emit(UserListSuccess(users: result));
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      print(e.toString());
      emit(UserListFailure(exception: e));
    }
  }
}
