import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/challenge.dart';
import 'package:oluko_app/models/submodels/personal_record.dart';
import 'package:oluko_app/repositories/challenge_repository.dart';
import 'package:oluko_app/utils/time_converter.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class PersonalRecordState {}

class PersonalRecordLoading extends PersonalRecordState {}

class PersonalRecordSuccess extends PersonalRecordState {
  List<PersonalRecord> personalRecords;
  PersonalRecordSuccess({this.personalRecords});
}

class PersonalRecordFailure extends PersonalRecordState {
  final dynamic exception;
  PersonalRecordFailure({this.exception});
}

class PersonalRecordBloc extends Cubit<PersonalRecordState> {
  PersonalRecordBloc() : super(PersonalRecordLoading());

  void get(String segmentId, String userId, BuildContext context) async {
    try {
      final List<Challenge> challengesList = await ChallengeRepository.getUserChallengesBySegmentId(segmentId, userId);
      final List<PersonalRecord> personalRecords = challengesList.map((challenge) {
        return PersonalRecord(
            date: challenge.completedAt != null
                ? TimeConverter.returnDateOnStringFormat(dateToFormat: challenge.completedAt, context: context)
                : '',
            image: challenge.image,
            title: challenge.challengeName);
      }).toList();

      emit(PersonalRecordSuccess(personalRecords: personalRecords));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(PersonalRecordFailure(exception: exception));
      rethrow;
    }
  }
}
