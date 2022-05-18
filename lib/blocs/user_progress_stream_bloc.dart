import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/dto/user_progress.dart';
import 'package:oluko_app/repositories/user_progress_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class UserProgressStreamState {}

class UserProgressLoading extends UserProgressStreamState {}

class UserProgressUpdate extends UserProgressStreamState {
  UserProgressUpdate({this.obj});
  final UserProgress obj;
}

class UserProgressRemove extends UserProgressStreamState {
  UserProgressRemove({this.obj});
  final UserProgress obj;
}

class UserProgressAdd extends UserProgressStreamState {
  UserProgressAdd({this.obj});
  final UserProgress obj;
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

  void getStream() {
    final DatabaseReference ref = UserProgressRepository.getReference();
    UserProgress userProgress;
    try {
      ref.onChildChanged.listen((event) {
        userProgress = getUserProgressFromObj(event.snapshot.value);
        emit(UserProgressUpdate(obj: userProgress));
      });
      ref.onChildAdded.listen((event) {
        userProgress = getUserProgressFromObj(event.snapshot.value);
        emit(UserProgressAdd(obj: userProgress));
      });
      ref.onChildRemoved.listen((event) {
        userProgress = getUserProgressFromObj(event.snapshot.value);
        emit(UserProgressRemove(obj: userProgress));
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

  UserProgress getUserProgressFromObj(Object value) {
    if (value != null) {
      Map<String, dynamic> obj = Map<String, dynamic>.from(value as Map);
      return UserProgress(id: obj['id'].toString(), progress: double.parse(obj['progress'].toString()));
    }
    return null;
  }
}
