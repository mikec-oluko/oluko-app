import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mvt_fitness/models/dto/api_response.dart';
import 'package:mvt_fitness/models/sign_up_request.dart';
import 'package:mvt_fitness/models/sign_up_response.dart';
import 'package:mvt_fitness/repositories/auth_repository.dart';
import 'package:mvt_fitness/utils/oluko_localizations.dart';
import 'package:mvt_fitness/utils/app_loader.dart';
import 'package:mvt_fitness/utils/app_messages.dart';
import 'package:mvt_fitness/utils/app_navigator.dart';

abstract class UserState {}

class SignupSuccess extends UserState {
  final SignUpResponse user;
  SignupSuccess({this.user});
}

class SignupLoading extends UserState {}

class SignupFailure extends UserState {
  final Exception exception;
  SignupFailure({this.exception});
}

class SignupBloc extends Cubit<UserState> {
  SignupBloc() : super(SignupLoading());

  final _repository = AuthRepository();

  Future<void> signUp(context, SignUpRequest request) async {
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
