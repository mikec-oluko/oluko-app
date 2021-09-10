import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/dto/api_response.dart';
import 'package:oluko_app/models/sign_up_request.dart';
import 'package:oluko_app/models/sign_up_response.dart';
import 'package:oluko_app/repositories/auth_repository.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/app_loader.dart';
import 'package:oluko_app/utils/app_messages.dart';
import 'package:oluko_app/utils/app_navigator.dart';

abstract class UserState {}

class SignupSuccess extends UserState {
  final SignUpResponse user;
  SignupSuccess({this.user});
}

class SignupLoading extends UserState {}

class SignupFailure extends UserState {
  final dynamic exception;
  SignupFailure({this.exception});
}

class SignupBloc extends Cubit<UserState> {
  SignupBloc() : super(SignupLoading());

  final _repository = AuthRepository();

  Future<void> signUp(BuildContext context, SignUpRequest request) async {
    if (request.password.contains(request.username)) {
      AppMessages.showSnackbar(
          context,
          OlukoLocalizations.of(context)
              .find('passwordShouldNotContainUsername'));
      emit(SignupFailure(
          exception: Exception(OlukoLocalizations.of(context)
              .find('passwordShouldNotContainUsername'))));
      return;
    }
    if (request.password.contains(request.email)) {
      AppMessages.showSnackbar(context,
          OlukoLocalizations.of(context).find('passwordShouldNotContainEmail'));
      emit(SignupFailure(
          exception: Exception(OlukoLocalizations.of(context)
              .find('passwordShouldNotContainEmail'))));
      return;
    }
    AppLoader.startLoading(context);

    ApiResponse apiResponse = await _repository.signUp(request);
    if (apiResponse.statusCode == 200) {
      SignUpResponse response = SignUpResponse.fromJson(apiResponse.data);
      _repository.sendEmailVerification(request);
      AppLoader.stopLoading();
      AppNavigator().returnToHome(context);
      emit(SignupSuccess(user: response));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(OlukoLocalizations.of(context).find('checkYourEmail')),
      ));
    } else {
      AppLoader.stopLoading();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(apiResponse.message[0]),
      ));
      emit(SignupFailure(exception: Exception(apiResponse.message[0])));
    }
  }
}
