import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';
import 'package:oluko_app/helpers/form_helper.dart';
import 'package:oluko_app/models/assessment.dart';
import 'package:oluko_app/models/dto/change_user_information.dart';
import 'package:oluko_app/repositories/assessment_repository.dart';
import 'package:oluko_app/repositories/user_repository.dart';
import 'package:oluko_app/utils/app_messages.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class UserInformationState {}

class Loading extends UserInformationState {}

class Success extends UserInformationState {
  final List<Assessment> assessments;
  Success({this.assessments});
}

class Failure extends UserInformationState {
  final dynamic exception;

  Failure({this.exception});
}

class UserInformationBloc extends Cubit<UserInformationState> {
  UserInformationBloc() : super(Loading());
  final _userRepository = UserRepository();

  Future<bool> updateUserInformation(UserInformation userInformation, String userId, BuildContext context,{bool isLoggedOut=false}) async {
    if (_checkAllNullsAndEmptys(userInformation)) {
      AppMessages.clearAndShowSnackbarTranslated(context, 'allFieldsRequired');
      return false;
    }
    if (userInformation.username == null) {
      AppMessages.clearAndShowSnackbarTranslated(context, 'usernameRequired');
      return false;
    }
    if (userInformation.state == null) {
      AppMessages.clearAndShowSnackbarTranslated(context, 'stateRequired');
      return false;
    }
    if (userInformation.lastName == null) {
      AppMessages.clearAndShowSnackbarTranslated(context, 'lastnameRequired');
      return false;
    }
    if (userInformation.firstName == null) {
      AppMessages.clearAndShowSnackbarTranslated(context, 'firstnameRequired');
      return false;
    }
    if (userInformation.email == null) {
      AppMessages.clearAndShowSnackbarTranslated(context, 'emailRequired');
      return false;
    } else if (!FormHelper.isEmail(userInformation.email)) {
      AppMessages.clearAndShowSnackbarTranslated(context, 'wrongEmailFormat');
      return false;
    }

    if (userInformation.country == null) {
      AppMessages.clearAndShowSnackbarTranslated(context, 'countryRequired');
      return false;
    }
    if ( userInformation.city == null) {
      AppMessages.clearAndShowSnackbarTranslated(context, 'cityRequired');
      return false;
    }

    final Response response = await _userRepository.updateUserInformation(userInformation, userId);
    List<String> messageList;
    if (response == null) {
      AppMessages.clearAndShowSnackbarTranslated(context, 'tokenExpired');
      return false;
    } else if (response.statusCode == 200) {
      if(!isLoggedOut){AppMessages.clearAndShowSnackbarTranslated(context, 'infoUpdateSuccess');}

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
