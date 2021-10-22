import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/models/assessment_assignment.dart';
import 'package:oluko_app/models/dto/api_response.dart';
import 'package:oluko_app/models/dto/login_request.dart';
import 'package:oluko_app/models/sign_up_request.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/repositories/assessment_assignment_repository.dart';
import 'package:oluko_app/repositories/auth_repository.dart';
import 'package:oluko_app/repositories/user_repository.dart';
import 'package:oluko_app/utils/app_loader.dart';
import 'package:oluko_app/utils/app_messages.dart';
import 'package:oluko_app/utils/app_navigator.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

abstract class AuthState {}

class AuthSuccess extends AuthState {
  final UserResponse user;
  final User firebaseUser;
  AuthSuccess({this.user, this.firebaseUser});
}

class AuthFailure extends AuthState {
  final dynamic exception;
  AuthFailure({this.exception});
}

class AuthLoading extends AuthState {}

class AuthGuest extends AuthState {}

class AuthBloc extends Cubit<AuthState> {
  AuthBloc() : super(AuthLoading()) {
    checkCurrentUser();
  }

  final _authRepository = AuthRepository();
  final _userRepository = UserRepository();

  Future<void> login(BuildContext context, LoginRequest request) async {
    if (request.email == null && request.userName.isEmpty && request.password.isEmpty) {
      AppMessages.showSnackbarTranslated(context, 'invalidUsernameOrPw');
      return;
    }

    if (request.email == null && request.userName.isEmpty) {
      AppMessages.showSnackbarTranslated(context, 'emailUsernameRequired');
      return;
    }

    if (request.password.isEmpty) {
      AppMessages.showSnackbarTranslated(context, 'passwordRequired');
      return;
    }
    AppLoader.startLoading(context);
    final ApiResponse apiResponse = await _authRepository.login(request);
    AppLoader.stopLoading();
    if (apiResponse.statusCode != 200) {
      //TODO: response should bring key apiResponse.message
      AppMessages.showSnackbarTranslated(context, 'invalidUsernameOrPw');
      emit(AuthFailure(exception: Exception(apiResponse.message)));
      return;
    }
    UserResponse user;
    if (request.email == null) {
      user = await _userRepository.getByUsername(request.userName);
    } else {
      user = await _userRepository.get(request.email);
    }

    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (user.currentPlan == -100) {
      FirebaseAuth.instance.signOut();
      AppMessages.showSnackbarTranslated(context, 'pleaseSubscribeToAPlanBeforeUsingTheApp');
      emit(AuthGuest());
      return;
    } else if (!firebaseUser.emailVerified) {
      //TODO: trigger to send another email
      await firebaseUser.updateEmail(user.email);
      firebaseUser.sendEmailVerification();
      FirebaseAuth.instance.signOut();
      AppMessages.showSnackbarTranslated(context, 'pleaseCheckYourEmail');
      emit(AuthGuest());
    } else {
      AuthRepository().storeLoginData(user);
      AppMessages.showSnackbar(context, '${OlukoLocalizations.get(context, 'welcome')}, ${user.firstName}');
      emit(AuthSuccess(user: user, firebaseUser: firebaseUser));
      navigateToNextScreen(context, firebaseUser.uid);
    }
  }

  void navigateToNextScreen(BuildContext context, String userId) async {
    AssessmentAssignment assessmentA = await AssessmentAssignmentRepository.getByUserId(userId);
    if (assessmentA != null && (assessmentA.seenByUser == null || !assessmentA.seenByUser)) {
      await AppNavigator().goToAssessmentVideos(context);
    } else {
      await AppNavigator().returnToHome(context);
    }
  }

  Future<void> loginWithGoogle(BuildContext context) async {
    UserCredential result = await _authRepository.signInWithGoogle();
    User firebaseUser = result.user;
    UserResponse userResponse = await UserRepository().get(firebaseUser.email);

    //TODO (Not implemented in MVP) If Firebase user document not found, create one.

    // if (userResponse == null) {
    //   UserResponse dbResponse = await _signUpWithSSO(firebaseUser);
    //   if (dbResponse == null) {
    //     FirebaseAuth.instance.signOut();
    //     emit(AuthFailure(
    //         exception: Exception('Error creating user in database.')));
    //     return;
    //   } else {
    //     userResponse = dbResponse;
    //   }
    // }

    if (!firebaseUser.emailVerified) {
      //TODO: trigger to send another email
      FirebaseAuth.instance.signOut();
      AppMessages.showSnackbar(context, OlukoLocalizations.get(context, 'pleaseCheckYourEmail'));
      emit(AuthGuest());
      return;
    }

    //If there is no associated user for this account
    if (userResponse == null) {
      FirebaseAuth.instance.signOut();
      AppMessages.showSnackbar(context, OlukoLocalizations.get(context, 'userForThisAccountNotFoundPleaseSignUp'));
      emit(AuthGuest());
      return;
    }

    AuthRepository().storeLoginData(userResponse);
    emit(AuthSuccess(user: userResponse, firebaseUser: firebaseUser));
    navigateToNextScreen(context, firebaseUser.uid);
  }

  Future<void> loginWithFacebook(BuildContext context) async {
    UserCredential result = await _authRepository.signInWithFacebook();
    User firebaseUser = result.user;
    UserResponse user = await UserRepository().get(firebaseUser.email);

    /*List<String> splitDisplayName = firebaseUser.displayName.split(' ');
    user.firstName = splitDisplayName[0];
    user.email = firebaseUser.email;
    user.firebaseId = firebaseUser.uid;
    if (splitDisplayName.length > 1) {
      user.lastName = splitDisplayName[1];
    }
    AuthRepository().storeLoginData(user);
    navigateToNextScreen(context, firebaseUser.uid);
    emit(AuthSuccess(user: user, firebaseUser: firebaseUser));*/

    if (!firebaseUser.emailVerified) {
      //TODO: trigger to send another email
      FirebaseAuth.instance.signOut();
      AppMessages.showSnackbar(context, OlukoLocalizations.get(context, 'pleaseCheckYourEmail'));
      emit(AuthGuest());
      return;
    }

    //If there is no associated user for this account
    if (user == null) {
      FirebaseAuth.instance.signOut();
      AppMessages.showSnackbar(context, OlukoLocalizations.get(context, 'userForThisAccountNotFoundPleaseSignUp'));
      emit(AuthGuest());
      return;
    }

    AuthRepository().storeLoginData(user);
    emit(AuthSuccess(user: user, firebaseUser: firebaseUser));
    navigateToNextScreen(context, firebaseUser.uid);
  }

  Future<UserResponse> retrieveLoginData() {
    return AuthRepository().retrieveLoginData();
  }

  Future<User> checkCurrentUser() async {
    final loggedUser = AuthRepository.getLoggedUser();
    final userData = await AuthRepository().retrieveLoginData();
    if (loggedUser != null && userData != null) {
      emit(AuthSuccess(user: userData, firebaseUser: loggedUser));
      return loggedUser;
    } else {
      emit(AuthGuest());
      return null;
    }
  }

  Future<void> logout(BuildContext context) async {
    final success = await AuthRepository().removeLoginData();
    if (success == true) {
      Navigator.pushNamedAndRemoveUntil(context, '/sign-up', (route) => false);
      emit(AuthGuest());
    }
  }

  Future<void> sendPasswordResetEmail(BuildContext context, LoginRequest loginRequest) async {
    if (loginRequest.email == null || loginRequest.email == '') {
      AppMessages.showSnackbar(context, OlukoLocalizations.get(context, 'enterEmail'));
      return;
    }

    await AuthRepository().sendPasswordResetEmail(loginRequest.email);
    AppMessages.showSnackbar(context, OlukoLocalizations.get(context, 'pleaseCheckYourEmailForInstructions'));
  }

  String getRandString(int len) {
    var random = Random.secure();
    var values = List<int>.generate(len, (i) => random.nextInt(255));
    return base64UrlEncode(values);
  }

  Future<UserResponse> _signUpWithSSO(User firebaseUser) async {
    List<String> splitDisplayName = firebaseUser.displayName.split(' ');
    SignUpRequest signUpRequest = SignUpRequest(
      email: firebaseUser.email,
      firstName: splitDisplayName[0],
      lastName: splitDisplayName[1],
      projectId: GlobalConfiguration().getValue('projectId'),
    );
    UserResponse response = await UserRepository().createSSO(signUpRequest);
    return response;
  }
}
