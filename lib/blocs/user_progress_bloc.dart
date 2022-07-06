import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/dto/user_progress.dart';
import 'package:oluko_app/models/submodels/friend_model.dart';
import 'package:oluko_app/repositories/user_progress_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class UserProgressState {}

class CreateUserProgressSuccess extends UserProgressState {
  UserProgress userProgress;
  CreateUserProgressSuccess({this.userProgress});
}

class HasStoriesSuccess extends UserProgressState {
  HasStoriesSuccess({this.hasStories});
  final bool hasStories;
}

class Failure extends UserProgressState {
  final dynamic exception;

  Failure({this.exception});
}

class UserProgressBloc extends Cubit<UserProgressState> {
  UserProgressBloc() : super(null);

  Future<void> create(String userId, double progress, List<FriendModel> friends) async {
    try {
      final UserProgress userProgress = await UserProgressRepository.create(userId, progress, friends);
      emit(CreateUserProgressSuccess(userProgress: userProgress));
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      emit(Failure(exception: e));
      rethrow;
    }
  }

  void update(String userId, double progress, List<FriendModel> friends) {
    try {
      UserProgressRepository.update(userId, progress, friends);
    } catch (exception, stackTrace) {
      Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(Failure(exception: exception));
      rethrow;
    }
  }

  void delete(String userId, List<FriendModel> friends) {
    try {
      UserProgressRepository.delete(userId, friends);
    } catch (exception, stackTrace) {
      Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(Failure(exception: exception));
      rethrow;
    }
  }
}
