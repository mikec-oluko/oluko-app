import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/repositories/user_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class CoachProfileState {}

class Loading extends CoachProfileState {}

class CoachProfileDataSuccess extends CoachProfileState {
  CoachProfileDataSuccess({this.coachProfile});
  final UserResponse coachProfile;
}

class CoachProfileFailure extends CoachProfileState {
  CoachProfileFailure({this.exception});
  final dynamic exception;
}

class CoachProfileBloc extends Cubit<CoachProfileState> {
  CoachProfileBloc() : super(Loading());

  void getCoachProfile(String coachId) async {
    try {
      final UserResponse coachProfileResponse = await UserRepository().getById(coachId);
      emit(CoachProfileDataSuccess(coachProfile: coachProfileResponse));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(CoachProfileFailure(exception: exception));
      rethrow;
    }
  }
}
