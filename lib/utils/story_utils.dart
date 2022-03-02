import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/challenge/challenge_segment_bloc.dart';
import 'package:oluko_app/blocs/segment_submission_bloc.dart';
import 'package:oluko_app/blocs/story_bloc.dart' as storyBloc;
import 'package:oluko_app/models/segment.dart';
import 'package:oluko_app/models/segment_submission.dart';
import 'package:oluko_app/utils/app_messages.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class StoryUtils {

  Future<void> createNewPRChallengeStory(BuildContext context, CreateSuccess state, int totalScore, String userId, Segment segment) async {
      final int result = totalScore ?? 0;
      final bool isNewPersonalRecord =
          await BlocProvider.of<ChallengeSegmentBloc>(context).isNewPersonalRecord(state.segmentSubmission.segmentId, userId, result);
      if (isNewPersonalRecord) {
        final String segmentTitle = '${segment.name} ${OlukoLocalizations.get(context, 'challenge')}';
        BlocProvider.of<storyBloc.StoryBloc>(context).createChallengeStory(
          segment,
          userId,
          segmentTitle,
          result.toString(),
          context,
        );
      }
  }

  Future<void> callBlocToCreateStory(BuildContext context, SegmentSubmission segmentSubmission, int totalScore, Segment segment) async {
    String segmentTitle = segment.name ?? '';
    if (segment.isChallenge) {
      segmentTitle += ' ${OlukoLocalizations.get(context, 'challenge')}';
    }
    final int result = totalScore ?? 0;
    BlocProvider.of<storyBloc.StoryBloc>(context).createStoryWithVideo(segmentSubmission, segmentTitle, result.toString(), segment, context);
    AppMessages.clearAndShowSnackbarTranslated(context, 'storyCreated');
  }
}