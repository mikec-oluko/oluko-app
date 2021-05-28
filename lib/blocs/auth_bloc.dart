import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/api_response.dart';
import 'package:oluko_app/models/login_request.dart';
import 'package:oluko_app/models/project_login_request.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/repositories/auth_repository.dart';
import 'package:oluko_app/repositories/user_repository.dart';
import 'package:oluko_app/utils/app_loader.dart';
import 'package:oluko_app/utils/app_messages.dart';
import 'package:oluko_app/utils/app_navigator.dart';

abstract class AuthState {}

class AuthSuccess extends AuthState {
  final UserResponse user;
  AuthSuccess({this.user});
}

class AuthFailure extends AuthState {
  final Exception exception;
  AuthFailure({this.exception});
}

class AuthLoading extends AuthState {}

class AuthGuest extends AuthState {}

class AuthBloc extends Cubit<AuthState> {
  AuthBloc() : super(AuthLoading());

  final _authRepository = AuthRepository();
  final _userRepository = UserRepository();

  Future<void> login(context, LoginRequest request) async {
    ApiResponse apiResponse = await _authRepository.login(request);
    //TODO: add project claim
    bool isLoggedIntoProject = await _authRepository.loginProject(
        new ProjectLoginRequest(projectId: "WnZEZDQDT9ZRU2nlpa86"));
    //
    if (apiResponse.statusCode != 200) {
      AppLoader.stopLoading();
      AppMessages.showSnackbar(context, apiResponse.message[0]);
      emit(AuthFailure(exception: Exception(apiResponse.message)));
      return;
    }
    UserResponse user = await _userRepository.get(request.email);
    AuthRepository().storeLoginData(user);
    AppLoader.stopLoading();
    await AppNavigator().returnToHome(context);
    emit(AuthSuccess(user: user));
  }

  Future<void> loginWithGoogle(context) async {
    UserCredential result = await _authRepository.signInWithGoogle();
    User firebaseUser = result.user;
    UserResponse user = UserResponse();
    List<String> splitDisplayName = firebaseUser.displayName.split(' ');
    user.firstName = splitDisplayName[0];
    user.email = firebaseUser.email;
    user.firebaseId = firebaseUser.uid;
    if (splitDisplayName.length > 1) {
      user.lastName = splitDisplayName[1];
    }
    AuthRepository().storeLoginData(user);
    await AppNavigator().returnToHome(context);
    emit(AuthSuccess(user: user));
  }

  Future<void> loginWithFacebook(context) async {
    UserCredential result = await _authRepository.signInWithFacebook();
    User firebaseUser = result.user;
    UserResponse user = UserResponse();
    List<String> splitDisplayName = firebaseUser.displayName.split(' ');
    user.firstName = splitDisplayName[0];
    user.email = firebaseUser.email;
    user.firebaseId = firebaseUser.uid;
    if (splitDisplayName.length > 1) {
      user.lastName = splitDisplayName[1];
    }
    AuthRepository().storeLoginData(user);
    await AppNavigator().returnToHome(context);
    emit(AuthSuccess(user: user));
  }

  Future<UserResponse> retrieveLoginData() {
    return AuthRepository().retrieveLoginData();
  }
}
