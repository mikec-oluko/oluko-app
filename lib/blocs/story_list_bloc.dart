import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/dto/story_dto.dart';
import 'package:oluko_app/models/dto/user_stories.dart';
import 'package:oluko_app/repositories/story_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class StoryListState {}

class StoryListLoading extends StoryListState {}

class StoryListSuccess extends StoryListState {
  StoryListSuccess({this.usersStories});
  final List<UserStories> usersStories;
}

class GetUnseenStories extends StoryListState {
  GetUnseenStories({this.hasUnseenStories});
  final bool hasUnseenStories;
}

class GetStoriesSuccess extends StoryListState {
  GetStoriesSuccess({this.stories});
  final List<Story> stories;
}

class StoryListUpdate extends StoryListState {
  StoryListUpdate({this.event});
  final Event event;
}

class StoryListFailure extends StoryListState {
  StoryListFailure({this.exception});
  final dynamic exception;
}

class StoryListBloc extends Cubit<StoryListState> {
  StoryListBloc() : super(StoryListLoading());

  StreamSubscription<Event> subscription;

  @override
  void dispose() {
    if (subscription != null) {
      subscription.cancel();
    }
  }

  void get(String userId) async {
    try {
      dynamic result = await StoryRepository().getAll(userId);
      emit(StoryListSuccess(usersStories: result as List<UserStories>));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(StoryListFailure(exception: exception));
      rethrow;
    }
  }

  void getStoriesFromUser(String userId, String userStoryId) async {
    try {
      final List<Story> stories = await StoryRepository().getStoriesFromUser(userId, userStoryId);
      emit(GetStoriesSuccess(stories: stories));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(StoryListFailure(exception: exception));
      rethrow;
    }
  }

  void checkForUnseenStories(String userId, String userStoryId) async {
    try {
      final bool hasUnseenStories = await StoryRepository().checkForUnseenStories(userId, userStoryId);
      emit(GetUnseenStories(hasUnseenStories: hasUnseenStories));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(StoryListFailure(exception: exception));
      rethrow;
    }
  }

  StreamSubscription<Event> getStream(String userId) {
    if (subscription == null) {
      subscription = StoryRepository().getSubscription(userId).listen((event) {
        emit(StoryListUpdate(event: event));
      });
    }
    return subscription;
  }
}
