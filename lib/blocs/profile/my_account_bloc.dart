import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/dto/change_user_information.dart';
import 'package:oluko_app/models/utils/oluko_bloc_exception.dart';
import 'package:oluko_app/services/mail_service.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class MyAccountState {}

class MyAccountLoading extends MyAccountState {}

class MyAccountSuccess extends MyAccountState {
  final bool formHasChanged;
  MyAccountSuccess({this.formHasChanged});
}
class MyAccountDispose extends MyAccountState {
  MyAccountDispose({this.formHasChanged});
  final bool formHasChanged;
}
class MyAccountFailure extends OlukoException with MyAccountState {
  final dynamic exception;
  MyAccountFailure({this.exception});
}

class MyAccountBloc extends Cubit<MyAccountState> {
  MyAccountBloc() : super(MyAccountLoading());

  Future<void> changeFormState(UserInformation _defaultUser,
      UserInformation newFields) async {
    try {
      if (newFields != _defaultUser) {
        emit(MyAccountSuccess(formHasChanged: true));
      } else {
        emit(MyAccountSuccess(formHasChanged: false));
      }
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(MyAccountFailure(exception: exception));
      rethrow;
    }
  }
    void emitMyAccountDispose() async {
    try {
      emit(MyAccountDispose());
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(MyAccountFailure(exception: exception));
      rethrow;
    }
  }
}
