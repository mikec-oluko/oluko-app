import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';
import 'package:oluko_app/helpers/form_helper.dart';
import 'package:oluko_app/models/assessment.dart';
import 'package:oluko_app/models/dto/change_user_information.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/repositories/assessment_repository.dart';
import 'package:oluko_app/repositories/auth_repository.dart';
import 'package:oluko_app/repositories/user_repository.dart';
import 'package:oluko_app/utils/app_messages.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class UserInformationState {}

class Loading extends UserInformationState {}

class Success extends UserInformationState {
  UserResponse userResponse;
  Success(this.userResponse);
}

class Failure extends UserInformationState {
  final dynamic exception;

  Failure({this.exception});
}

class UserInformationBloc extends Cubit<UserInformationState> {
  UserInformationBloc() : super(Loading());
  final _userRepository = UserRepository();

  Future<bool> updateUserInformation(
      UserInformation userInformation, String userId, BuildContext context,
      {bool isLoggedOut = false}) async {
    if (_checkAllNullsAndEmptys(userInformation)) {
      AppMessages.clearAndShowSnackbarTranslated(context, 'allFieldsRequired');
      return false;
    }
    if (userInformation.username == null || userInformation.username.isEmpty) {
      AppMessages.clearAndShowSnackbarTranslated(context, 'usernameRequired');
      return false;
    }
    if (userInformation.state == null || userInformation.state.isEmpty) {
      AppMessages.clearAndShowSnackbarTranslated(context, 'stateRequired');
      return false;
    }
    if (userInformation.lastName == null || userInformation.lastName.isEmpty) {
      AppMessages.clearAndShowSnackbarTranslated(context, 'lastnameRequired');
      return false;
    }
    if (userInformation.firstName == null ||
        userInformation.firstName.isEmpty) {
      AppMessages.clearAndShowSnackbarTranslated(context, 'firstnameRequired');
      return false;
    }
    if (userInformation.email == null || userInformation.email.isEmpty) {
      AppMessages.clearAndShowSnackbarTranslated(context, 'emailRequired');
      return false;
    } else if (!FormHelper.isEmail(userInformation.email)) {
      AppMessages.clearAndShowSnackbarTranslated(context, 'wrongEmailFormat');
      return false;
    }

    if (userInformation.country == null || userInformation.country.isEmpty) {
      AppMessages.clearAndShowSnackbarTranslated(context, 'countryRequired');
      return false;
    }
    if (userInformation.city == null || userInformation.city.isEmpty) {
      AppMessages.clearAndShowSnackbarTranslated(context, 'cityRequired');
      return false;
    }
    final Response response =
        await _userRepository.updateUserInformation(userInformation, userId);
    List<String> messageList;
    if (response == null) {
      AppMessages.clearAndShowSnackbarTranslated(context, 'tokenExpired');
      return false;
    } else if (response.statusCode == 200) {
      if (!isLoggedOut) {
        AppMessages.clearAndShowSnackbarTranslated(
            context, 'infoUpdateSuccess');
      }
      final UserResponse user = await UserRepository().getById(userId);
      AuthRepository().storeLoginData(user);
      emit(Success(user));
      return true;
    } else {
      AppMessages.clearAndShowSnackbarTranslated(context, 'errorMessage');
      return false;
    }
  }

  bool _checkAllNullsAndEmptys(UserInformation userInformation) {
    return userInformation.username.isEmpty &&
        userInformation.firstName.isEmpty &&
        userInformation.lastName.isEmpty &&
        userInformation.email.isEmpty &&
        userInformation.country.isEmpty &&
        userInformation.city.isEmpty &&
        userInformation.state.isEmpty;
  }
}
