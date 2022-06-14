import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/models/utils/oluko_bloc_exception.dart';
import 'package:oluko_app/services/mail_service.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class MailState {}

class MailLoading extends MailState {}

class MailSuccess extends MailState {}

class MailFailure extends OlukoException with MailState {
  final dynamic exception;
  MailFailure({this.exception});
}

class MailBloc extends Cubit<MailState> {
  MailBloc() : super(MailLoading());

  Future<void> sendEmail(String username, String email, String message, String phone) async {
    try {
      MailService.send(username,email,message,phone);
      emit(MailSuccess());
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(MailFailure(exception: exception));
      rethrow;
    }
  }
}
