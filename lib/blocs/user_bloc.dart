import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/api_response.dart';
import 'package:oluko_app/models/sign_up_request.dart';
import 'package:oluko_app/models/sign_up_response.dart';
import 'package:oluko_app/repositories/auth_repository.dart';
import 'package:oluko_app/utils/OlukoLocalizations.dart';
import 'package:oluko_app/utils/app_loader.dart';
import 'package:oluko_app/utils/app_messages.dart';
import 'package:oluko_app/utils/app_navigator.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

abstract class UserState {}

class UserSuccess extends UserState {
  final SignUpResponse user;
  UserSuccess({this.user});
}

class UserLoading extends UserState {}

class UserFailure extends UserState {
  final Exception exception;
  UserFailure({this.exception});
}

class UserBloc extends Cubit<UserState> {
  UserBloc() : super(UserLoading());

  final _repository = AuthRepository();

  Future<void> signUp(context, SignUpRequest request) async {
    if (request.password.contains(request.username)) {
      AppMessages.showSnackbar(context, OlukoLocalizations.of(context).find('passwordShouldNotContainUsername'));
      emit(UserFailure(exception: Exception(OlukoLocalizations.of(context).find('passwordShouldNotContainUsername'))));
      return;
    }
    if (request.password.contains(request.email)) {
      AppMessages.showSnackbar(context, OlukoLocalizations.of(context).find('passwordShouldNotContainEmail'));
      emit(UserFailure(exception: Exception(OlukoLocalizations.of(context).find('passwordShouldNotContainEmail'))));
      return;
    }
    AppLoader.startLoading(context);

    ApiResponse apiResponse = await _repository.signUp(request);
    if (apiResponse.statusCode == 200) {
      SignUpResponse response = SignUpResponse.fromJson(apiResponse.data);
      _repository.sendEmailVerification(request);
      AppLoader.stopLoading();
      AppNavigator().returnToHome(context);
      emit(UserSuccess(user: response));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(OlukoLocalizations.of(context).find('checkYourEmail')),
      ));
    } else {
      AppLoader.stopLoading();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(apiResponse.message[0]),
      ));
      emit(UserFailure(exception: Exception(apiResponse.message[0])));
    }
  }
}
