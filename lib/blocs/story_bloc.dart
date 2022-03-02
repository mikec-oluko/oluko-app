import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/dto/story_dto.dart';
import 'package:oluko_app/models/segment.dart';
import 'package:oluko_app/models/segment_submission.dart';
import 'package:oluko_app/models/submodels/enrollment_segment.dart';
import 'package:oluko_app/repositories/story_repository.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/segment_utils.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class StoryState {}

class CreateSuccess extends StoryState {
  Story story;
  CreateSuccess({this.story});
}

class HasStoriesSuccess extends StoryState {
  HasStoriesSuccess({this.hasStories});
  final bool hasStories;
}

class Failure extends StoryState {
  final dynamic exception;

  Failure({this.exception});
}

class StoryBloc extends Cubit<StoryState> {
  StoryBloc() : super(null);

  Future<void> createStoryWithVideo(
      SegmentSubmission segmentSubmission, String segmentTitle, String result, Segment segment, BuildContext context) async {
    try {
      final String description = getSegmetDescription(segment, context);
      final String newPRResult = gerNewPRResult(context, result);

      final Story newStory = await StoryRepository.createStoryWithVideo(segmentSubmission, segmentTitle, newPRResult, description);
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

  Future<void> createChallengeStory(
      Segment segment, String userId, String segmentTitle, String result, BuildContext context) async {
    try {
      final String description = getSegmetDescription(segment, context);
      final String newPRResult = gerNewPRResult(context, result);

      final Story newStory = await StoryRepository.createStoryForChallenge(segment, userId, segmentTitle, newPRResult, description);
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

  String gerNewPRResult(BuildContext context, String result) => '${OlukoLocalizations.get(context, 'newPR')} $result';

  String getSegmetDescription(Segment segment, BuildContext context) {
    String description = '${SegmentUtils.getRoundTitle(segment, context)}: ';
    final List<String> workouts = SegmentUtils.getWorkouts(segment);
    for (var i = 0; i < workouts.length; i++) {
      final String workout = workouts[i];
      description += workout;
      if (i != workouts.length - 1) {
        description += ', ';
      }
    }
    return description;
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

  void hasStories(String userId) async {
    try {
      final bool hasStories = await StoryRepository().hasStories(userId);
      emit(HasStoriesSuccess(hasStories: hasStories));
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
