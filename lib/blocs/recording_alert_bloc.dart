import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_update_bloc.dart';
import 'package:oluko_app/models/challenge.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/repositories/user_repository.dart';
import 'package:oluko_app/repositories/user_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class RecordingAlertState {}

class Loading extends RecordingAlertState {}

class Failure extends RecordingAlertState {
  final dynamic exception;
  Failure({this.exception});
}

class UpdateRecordingAlertSuccess extends RecordingAlertState {
  final UserResponse userResponse;
  UpdateRecordingAlertSuccess({this.userResponse});
}

class RecordingAlertBloc extends Cubit<RecordingAlertState> {
  RecordingAlertBloc() : super(Loading());

  void updateRecordingAlert(UserResponse user) async {
    try {
        user = await UserRepository().updateRecordingAlert(user);
      emit(UpdateRecordingAlertSuccess(userResponse: user));
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
