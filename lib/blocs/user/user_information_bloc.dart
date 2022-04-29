import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';
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

  updateUserInformation(ChangeUserInformation userInformation, String userId, BuildContext context) async {
    if (_checkAllNullsAndEmptys(userInformation)) {
      AppMessages.clearAndShowSnackbarTranslated(context, 'allFieldsRequired');
      return;
    }
    if (userInformation.username.isEmpty || userInformation.username == null) {
      AppMessages.clearAndShowSnackbarTranslated(context, 'usernameRequired');
      return;
    }
    if (userInformation.state.isEmpty || userInformation.state == null) {
      AppMessages.clearAndShowSnackbarTranslated(context, 'stateRequired');
      return;
    }
    if (userInformation.lastName.isEmpty || userInformation.lastName == null) {
      AppMessages.clearAndShowSnackbarTranslated(context, 'lastnameRequired');
      return;
    }
    if (userInformation.firstName.isEmpty || userInformation.firstName == null) {
      AppMessages.clearAndShowSnackbarTranslated(context, 'firstnameRequired');
      return;
    }
    if (userInformation.email.isEmpty || userInformation.email == null) {
      AppMessages.clearAndShowSnackbarTranslated(context, 'emailRequired');
      return;
    }
    if (userInformation.country.isEmpty || userInformation.country == null) {
      AppMessages.clearAndShowSnackbarTranslated(context, 'countryRequired');
      return;
    }
    if (userInformation.city.isEmpty || userInformation.city == null) {
      AppMessages.clearAndShowSnackbarTranslated(context, 'cityRequired');
      return;
    }
   
     final Response response = await _userRepository.updateUserInformation(userInformation, userId);
      if (response.statusCode == 200) {
       AppMessages.clearAndShowSnackbarTranslated(context, 'infoUpdateSuccess');
     }
     else{
       AppMessages.clearAndShowSnackbarTranslated(context, 'uploadFailed');
     }
  }

  bool _checkAllNullsAndEmptys(ChangeUserInformation userInformation) {
    return userInformation.username.isEmpty &&
        userInformation.firstName.isEmpty &&
        userInformation.lastName.isEmpty &&
        userInformation.email.isEmpty &&
        userInformation.country.isEmpty &&
        userInformation.city.isEmpty &&
        userInformation.state.isEmpty;
  }
}
