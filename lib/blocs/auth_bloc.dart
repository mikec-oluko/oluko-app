import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/dto/api_response.dart';
import 'package:oluko_app/models/dto/login_request.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/repositories/auth_repository.dart';
import 'package:oluko_app/repositories/user_repository.dart';
import 'package:oluko_app/utils/app_loader.dart';
import 'package:oluko_app/utils/app_messages.dart';
import 'package:oluko_app/utils/app_navigator.dart';

abstract class AuthState {}

class AuthSuccess extends AuthState {
  final UserResponse user;
  final User firebaseUser;
  AuthSuccess({this.user, this.firebaseUser});
}

class AuthFailure extends AuthState {
  final Exception exception;
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

  Future<void> login(context, LoginRequest request) async {
    ApiResponse apiResponse = await _authRepository.login(request);
    if (apiResponse.statusCode != 200) {
      AppLoader.stopLoading();
      AppMessages.showSnackbar(context, apiResponse.message[0]);
      emit(AuthFailure(exception: Exception(apiResponse.message)));
      return;
    }
    UserResponse user = await _userRepository.get(request.email);
    AuthRepository().storeLoginData(user);
    AppLoader.stopLoading();
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (!firebaseUser.emailVerified) {
      //TODO: trigger to send another email
      FirebaseAuth.instance.signOut();
      AppMessages.showSnackbar(
          context, 'Please check your Email for account confirmation.');
      emit(AuthGuest());
    } else {
      AppMessages.showSnackbar(context, 'Welcome, ${user.firstName}');
      emit(AuthSuccess(user: user, firebaseUser: firebaseUser));
    }
    await AppNavigator().returnToHome(context);
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
    emit(AuthSuccess(user: user, firebaseUser: firebaseUser));
    await AppNavigator().returnToHome(context);
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
    emit(AuthSuccess(user: user, firebaseUser: firebaseUser));
  }

  Future<UserResponse> retrieveLoginData() {
    return AuthRepository().retrieveLoginData();
  }

  Future<void> checkCurrentUser() async {
    final loggedUser = AuthRepository.getLoggedUser();
    final userData = await AuthRepository().retrieveLoginData();
    if (loggedUser != null && userData != null) {
      emit(AuthSuccess(user: userData, firebaseUser: loggedUser));
    } else {
      emit(AuthGuest());
    }
  }

  Future<void> logout(context) async {
    final success = await AuthRepository().removeLoginData();
    if (success == true) {
      emit(AuthGuest());
    }
  }

  Future<void> sendPasswordResetEmail(
      context, LoginRequest loginRequest) async {
    //TODO: unused variable final success =
    await AuthRepository().sendPasswordResetEmail(loginRequest.email);
    AppMessages.showSnackbar(
        context, 'Please check your email for instructions.');
  }
}
