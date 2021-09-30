import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/dto/story_dto.dart';
import 'package:oluko_app/models/movement_submission.dart';
import 'package:oluko_app/repositories/story_repository.dart';
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

  Future<void> createStory(MovementSubmission movementSubmission) async {
    try {
      final Story newStory = await StoryRepository.createStory(movementSubmission);
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
}
