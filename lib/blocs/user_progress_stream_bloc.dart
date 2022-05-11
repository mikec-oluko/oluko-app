import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/dto/user_progress.dart';
import 'package:oluko_app/repositories/user_progress_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class UserProgressStreamState {}

class UserProgressLoading extends UserProgressStreamState {}

class GetUserProgressSuccess extends UserProgressStreamState {
  GetUserProgressSuccess({this.usersProgress});
  final List<UserProgress> usersProgress;
}

class UserProgressUpdate extends UserProgressStreamState {
  UserProgressUpdate({this.event});
  final DatabaseEvent event;
}

class UserProgressFailure extends UserProgressStreamState {
  UserProgressFailure({this.exception});
  final dynamic exception;
}

class UserProgressStreamBloc extends Cubit<UserProgressStreamState> {
  UserProgressStreamBloc() : super(UserProgressLoading());

  StreamSubscription<DatabaseEvent> usersProgressStream;

  @override
  void dispose() {
    if (usersProgressStream != null) {
      usersProgressStream.cancel();
      usersProgressStream = null;
    }
  }

  void get(String userId) async {
    try {
      List<UserProgress> usersProgress = await UserProgressRepository.getAll(userId);
      emit(GetUserProgressSuccess(usersProgress: usersProgress as List<UserProgress>));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(UserProgressFailure(exception: exception));
      rethrow;
    }
  }

  StreamSubscription<DatabaseEvent> getStream() {
    try {
      return usersProgressStream ??= UserProgressRepository.getSubscription().listen((event) {
        print(event.snapshot.value);
        emit(UserProgressUpdate(event: event));
      });
    } catch (exception, stackTrace) {
      Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(UserProgressFailure(exception: exception));
      rethrow;
    }
  }
}
