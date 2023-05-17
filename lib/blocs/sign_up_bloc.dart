import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/models/dto/api_response.dart';
import 'package:oluko_app/models/dto/login_request.dart';
import 'package:oluko_app/models/sign_up_request.dart';
import 'package:oluko_app/models/sign_up_response.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/repositories/auth_repository.dart';
import 'package:oluko_app/repositories/user_repository.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/app_loader.dart';
import 'package:oluko_app/utils/app_messages.dart';

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
      AppMessages.clearAndShowSnackbar(context, OlukoLocalizations.of(context).find('passwordShouldNotContainUsername'));
      emit(SignupFailure(exception: Exception(OlukoLocalizations.of(context).find('passwordShouldNotContainUsername'))));
      return;
    }
    if (request.password.contains(request.email)) {
      AppMessages.clearAndShowSnackbar(context, OlukoLocalizations.get(context, 'passwordShouldNotContainEmail'));
      emit(SignupFailure(exception: Exception(OlukoLocalizations.of(context).find('passwordShouldNotContainEmail'))));
      return;
    }
    AppLoader.startLoading(context);

    ApiResponse apiResponse = await _repository.signUp(request);
    if (apiResponse.statusCode == 200) {
      SignUpResponse response = SignUpResponse.fromJson(apiResponse.data);
      UserResponse _userCreated = await UserRepository().get(response.email);
      AppLoader.stopLoading();
      BlocProvider.of<AuthBloc>(context).login(context,
          LoginRequest(email: request.email, password: request.password, userName: request.username, projectId: GlobalConfiguration().getString('projectId')));
      emit(SignupSuccess(user: response));
      /*ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(OlukoLocalizations.get(context, 'checkYourEmail')),
      ));*/
    } else {
      AppLoader.stopLoading();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(apiResponse.message.replaceAll(_removeSpecialChars(), '')),
      ));
      emit(SignupFailure(exception: Exception(apiResponse.message.replaceAll(_removeSpecialChars(), ''))));
    }
  }

  RegExp _removeSpecialChars() => RegExp('[^A-Za-z0-9 ]');
}
