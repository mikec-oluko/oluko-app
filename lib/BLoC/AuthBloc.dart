import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/ApiResponse.dart';
import 'package:oluko_app/models/LoginRequest.dart';
import 'package:oluko_app/models/UserResponse.dart';
import 'package:oluko_app/repositories/AuthRepository.dart';
import 'package:oluko_app/repositories/UserRepository.dart';
import 'package:oluko_app/utils/AppLoader.dart';
import 'package:oluko_app/utils/AppMessages.dart';
import 'package:oluko_app/utils/AppNavigator.dart';

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
    if (apiResponse.statusCode != 200) {
      AppLoader.stopLoading();
      AppMessages.showSnackbar(context, apiResponse.message[0]);
      emit(AuthFailure(exception: Exception(apiResponse.message)));
      return;
    }
    UserResponse user = await _userRepository.get(request.email);
    AuthRepository.storeLoginData(user);
    AppLoader.stopLoading();
    await AppNavigator().returnToHome(context);
    emit(AuthSuccess(user: user));
  }

  Future<void> loginWithGoogle(context) async {
    AuthResult result = await _authRepository.signInWithGoogle();
    FirebaseUser firebaseUser = result.user;
    UserResponse user = UserResponse();
    List<String> splitDisplayName = firebaseUser.displayName.split(' ');
    user.firstName = splitDisplayName[0];
    user.email = firebaseUser.email;
    user.firebaseId = firebaseUser.uid;
    if (splitDisplayName.length > 1) {
      user.lastName = splitDisplayName[1];
    }
    AuthRepository.storeLoginData(user);
    await AppNavigator().returnToHome(context);
    emit(AuthSuccess(user: user));
  }

  Future<void> loginWithFacebook(context) async {
    AuthResult result = await _authRepository.signInWithFacebook();
    FirebaseUser firebaseUser = result.user;
    UserResponse user = UserResponse();
    List<String> splitDisplayName = firebaseUser.displayName.split(' ');
    user.firstName = splitDisplayName[0];
    user.email = firebaseUser.email;
    user.firebaseId = firebaseUser.uid;
    if (splitDisplayName.length > 1) {
      user.lastName = splitDisplayName[1];
    }
    AuthRepository.storeLoginData(user);
    await AppNavigator().returnToHome(context);
    emit(AuthSuccess(user: user));
  }

  Future<UserResponse> retrieveLoginData() {
    return AuthRepository.retrieveLoginData();
  }
}
