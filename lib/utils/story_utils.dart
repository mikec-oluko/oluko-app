import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/challenge/challenge_segment_bloc.dart';
import 'package:oluko_app/blocs/segment_submission_bloc.dart';
import 'package:oluko_app/blocs/story_bloc.dart' as storyBloc;
import 'package:oluko_app/models/enums/segment_type_enum.dart';
import 'package:oluko_app/models/segment.dart';
import 'package:oluko_app/models/segment_submission.dart';
import 'package:oluko_app/models/personal_record.dart';
import 'package:oluko_app/repositories/personal_record_repository.dart';
import 'package:oluko_app/utils/app_messages.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class StoryUtils {
  static Future<void> createNewPRChallengeStory(BuildContext context, int totalScore, String userId, Segment segment, {bool isDurationRecord = false}) async {
    final int result = totalScore ?? 0;
    final List<PersonalRecord> pRList = await PersonalRecordRepository.getByUserAndChallengeId(userId, segment.id);
    bool isNewPersonalRecord = true;
    if (pRList.isNotEmpty) {
      if (segment.type == SegmentTypeEnum.Rounds) {
        isNewPersonalRecord = pRList[0].value < result;
      } else {
        isNewPersonalRecord = pRList[0].value > result;
      }
    }
    if (isNewPersonalRecord) {
      final String segmentTitle = '${segment.name} ${OlukoLocalizations.get(context, 'challenge')}';
      BlocProvider.of<storyBloc.StoryBloc>(context).createChallengeStory(segment, userId, segmentTitle, result, context, isDurationRecord: isDurationRecord);
    }
  }

  static Future<void> callBlocToCreateStory(BuildContext context, SegmentSubmission segmentSubmission, int totalScore, Segment segment) async {
    String segmentTitle = segment.name ?? '';
    if (segment.isChallenge) {
      segmentTitle += ' ${OlukoLocalizations.get(context, 'challenge')}';
    }
    final int result = totalScore ?? 0;
    BlocProvider.of<storyBloc.StoryBloc>(context).createStoryWithVideo(segmentSubmission, segmentTitle, result.toString(), segment, context);
    AppMessages.clearAndShowSnackbarTranslated(context, 'storyCreated');
  }
}
