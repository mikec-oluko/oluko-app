import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';
import 'package:oluko_app/helpers/form_helper.dart';
import 'package:oluko_app/models/assessment.dart';
import 'package:oluko_app/models/dto/change_user_information.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/repositories/auth_repository.dart';
import 'package:oluko_app/repositories/user_repository.dart';
import 'package:oluko_app/utils/app_messages.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class UserInformationState {}

class Loading extends UserInformationState {}

class UserInformationSuccess extends UserInformationState {
  UserResponse userResponse;
  UserInformationSuccess({this.userResponse});
}

class UserInformationFailure extends UserInformationState {
  final bool tokenExpired;

  UserInformationFailure({this.tokenExpired = false});
}

class UserInformationBloc extends Cubit<UserInformationState> {
  UserInformationBloc() : super(Loading());
  final _userRepository = UserRepository();

  Future<bool> updateUserInformation(UserInformation userInformation, String userId, BuildContext context, {bool isLoggedOut = false}) async {
    if (_checkAllNullsAndEmptys(userInformation)) {
      AppMessages.clearAndShowSnackbarTranslated(context, 'allFieldsRequired');
      return false;
    }
    if (userInformation.username == null || userInformation.username.isEmpty) {
      AppMessages.clearAndShowSnackbarTranslated(context, 'usernameRequired');
      return false;
    }
    if (userInformation.lastName == null || userInformation.lastName.isEmpty) {
      AppMessages.clearAndShowSnackbarTranslated(context, 'lastnameRequired');
      return false;
    }
    if (userInformation.firstName == null || userInformation.firstName.isEmpty) {
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
    final Response response = await _userRepository.updateUserInformation(userInformation, userId);
    List<String> messageList;
    if (response == null) {
      emit(UserInformationFailure(tokenExpired: true));
      return false;
    } else if (response.statusCode == 200) {
      final UserResponse user = await UserRepository().getById(userId);
      AuthRepository().storeLoginData(user);
      emit(UserInformationSuccess(userResponse: user));
      return true;
    } else {
      emit(UserInformationFailure());
      return false;
    }
  }

  bool _checkAllNullsAndEmptys(UserInformation userInformation) {
    return userInformation.username.isEmpty && userInformation.firstName.isEmpty && userInformation.lastName.isEmpty && userInformation.email.isEmpty;
  }

  Future<bool> sendDeleteConfirmation(String userId) async {
    try {
      final Response response = await UserRepository().sendDeleteConfirmation(userId);
      if (response != null) {
        emit(UserInformationSuccess());
        return true;
      } else {
        emit(UserInformationFailure(tokenExpired: true));
        return false;
      }
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
