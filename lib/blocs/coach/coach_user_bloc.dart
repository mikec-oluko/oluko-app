import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/coach_user.dart';
import 'package:oluko_app/repositories/user_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class CoachUserState {}

class CoachUserLoading extends CoachUserState {}

class CoachUserSuccess extends CoachUserState {
  final CoachUser coach;
  CoachUserSuccess({this.coach});
}

class CoachUserFailure extends CoachUserState {
  final dynamic exception;
  CoachUserFailure({this.exception});
}

class CoachUserBloc extends Cubit<CoachUserState> {
  CoachUserBloc() : super(CoachUserLoading());

  void get(String userId) async {
    emit(CoachUserLoading());
    try {
      CoachUser coach = await UserRepository().getCoachById(userId);
      emit(CoachUserSuccess(coach: coach));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(CoachUserFailure(exception: exception));
      rethrow;
    }
  }
}
