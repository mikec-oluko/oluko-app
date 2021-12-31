import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/challenge.dart';
import 'package:oluko_app/repositories/course_enrollment_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class ChallengeState {}

class Loading extends ChallengeState {}

class Failure extends ChallengeState {
  final dynamic exception;
  Failure({this.exception});
}

class GetChallengeSuccess extends ChallengeState {
  final List<Challenge> challenges;
  GetChallengeSuccess({this.challenges});
}


class ChallengeBloc extends Cubit<ChallengeState> {
  ChallengeBloc() : super(Loading());

  void get(String userId) async {
    try {
      List<Challenge> challenges =
          await CourseEnrollmentRepository().getUserChallengesByUserId(userId);
      emit(GetChallengeSuccess(
          challenges: challenges));
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
