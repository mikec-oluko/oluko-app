import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/users_selfies.dart';
import 'package:oluko_app/repositories/users_selfies.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class UsersSelfiesState {}

class Loading extends UsersSelfiesState {}

class UsersSelfiesSuccess extends UsersSelfiesState {
  final UsersSelfies usersSelfies;
  UsersSelfiesSuccess({this.usersSelfies});
}

class Failure extends UsersSelfiesState {
  final dynamic exception;
  Failure({this.exception});
}

class UsersSelfiesBloc extends Cubit<UsersSelfiesState> {
  UsersSelfiesBloc() : super(Loading());

  void getUsersSelfies() async {
    emit(Loading());
    try {
      UsersSelfies usersSelfies = await UsersSelfiesRepository.getUsersSelfies();
      emit(UsersSelfiesSuccess(usersSelfies: usersSelfies));
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
