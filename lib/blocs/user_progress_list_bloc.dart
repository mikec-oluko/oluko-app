import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/user_progress_stream_bloc.dart';
import 'package:oluko_app/models/dto/user_progress.dart';
import 'package:oluko_app/repositories/user_progress_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class UserProgressListState {}

class UserProgressListLoading extends UserProgressListState {}

class GetUserProgressSuccess extends UserProgressListState {
  GetUserProgressSuccess({this.usersProgress});
  final Map<String, UserProgress> usersProgress;
}

class UserProgressFailure extends UserProgressListState {
  UserProgressFailure({this.exception});
  final dynamic exception;
}

class UserProgressListBloc extends Cubit<UserProgressListState> {
  UserProgressListBloc() : super(UserProgressListLoading());

  StreamSubscription<DatabaseEvent> usersProgressStream;

  void get(String userId) async {
    try {
      Map<String, UserProgress> usersProgress = await UserProgressRepository.getAll(userId);
      emit(GetUserProgressSuccess(usersProgress: usersProgress));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(UserProgressFailure(exception: exception));
      rethrow;
    }
  }
}
