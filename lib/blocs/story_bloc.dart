import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/dto/story_dto.dart';
import 'package:oluko_app/models/segment_submission.dart';
import 'package:oluko_app/repositories/story_repository.dart';
import 'package:oluko_app/utils/app_messages.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class StoryState {}

class CreateSuccess extends StoryState {
  Story story;
  CreateSuccess({this.story});
}

class Failure extends StoryState {
  final dynamic exception;

  Failure({this.exception});
}

class StoryBloc extends Cubit<StoryState> {
  StoryBloc() : super(null);

  Future<void> createStory(SegmentSubmission segmentSubmission) async {
    try {
      final Story newStory = await StoryRepository.createStory(segmentSubmission);
      emit(CreateSuccess(story: newStory));
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      emit(Failure(exception: e));
      rethrow;
    }
  }

  void setStoryAsSeen(String userId, String userStoryId, String storyId) {
    try {
      StoryRepository.setStoryAsSeen(userId, userStoryId, storyId);
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
