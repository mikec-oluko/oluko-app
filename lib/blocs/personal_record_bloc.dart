import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/enums/personal_record_param.dart';
import 'package:oluko_app/models/personal_record.dart';
import 'package:oluko_app/models/segment.dart';
import 'package:oluko_app/repositories/personal_record_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class PersonalRecordState {}

class PersonalRecordLoading extends PersonalRecordState {}

class PersonalRecordSuccess extends PersonalRecordState {
  List<PersonalRecord> personalRecords;
  PersonalRecordSuccess({this.personalRecords});
}

class CreatePRSuccess extends PersonalRecordState {
  CreatePRSuccess();
}

class PersonalRecordFailure extends PersonalRecordState {
  final dynamic exception;
  PersonalRecordFailure({this.exception});
}

class PersonalRecordBloc extends Cubit<PersonalRecordState> {
  PersonalRecordBloc() : super(PersonalRecordLoading());

  void get(String segmentId, String userId) async {
    try {
      List<PersonalRecord> personalRecords = await PersonalRecordRepository.getByUserAndChallengeId(userId, segmentId);
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

  void create(Segment segment, CourseEnrollment courseEnrollment, int totalScore, PersonalRecordParam parameter, bool doneFromProfile) async {
    try {
      if (totalScore > 0) {
        await PersonalRecordRepository.create(totalScore, parameter, courseEnrollment, segment, doneFromProfile);
      }
      emit(CreatePRSuccess());
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
