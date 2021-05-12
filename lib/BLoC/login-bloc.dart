import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:oluko_app/models/api-response.dart';
import 'package:oluko_app/models/login-request.dart';
import 'package:oluko_app/models/states/login-state.dart';
import 'package:oluko_app/models/user-response.dart';
import 'package:oluko_app/providers/log-in-provider.dart';
import 'package:oluko_app/providers/user-provider.dart';
import 'package:oluko_app/services/loader-service.dart';
import 'package:oluko_app/services/login-service.dart';
import 'package:oluko_app/services/snackbar-service.dart';
import 'bloc.dart';

class LoginBloc implements Bloc {
  var _loginResponse;
  UserResponse get response => _loginResponse;

  final _provider = LoginProvider();
  final _userProvider = UserProvider();
  final _controller = StreamController<LoginState>.broadcast();
  Stream<LoginState> get stream => _controller.stream;

  Future<void> login(context, LoginRequest request) async {
    ApiResponse apiResponse = await _provider.login(request);
    if (apiResponse.statusCode != 200) {
      LoaderService.stopLoading();
      SnackbarService.showSnackbar(context, apiResponse.message[0]);
      _controller.sink.addError(LoginState(
          error: apiResponse.error, errorMessages: apiResponse.message));
      return;
    }
    UserResponse user = await _userProvider.get(request.email);
    LoginService.storeLoginData(user);
    LoaderService.stopLoading();
    _controller.sink.add(LoginState(user: user));
  }

  Future<void> loginWithGoogle(context) async {
    AuthResult result = await _provider.signInWithGoogle();
    FirebaseUser firebaseUser = result.user;
    UserResponse user = UserResponse();
    List<String> splitDisplayName = firebaseUser.displayName.split(' ');
    user.firstName = splitDisplayName[0];
    user.email = firebaseUser.email;
    user.firebaseId = firebaseUser.uid;
    if (splitDisplayName.length > 1) {
      user.lastName = splitDisplayName[1];
    }
    LoginService.storeLoginData(user);
    _controller.sink.add(LoginState(user: user));
  }

  Future<void> loginWithFacebook(context) async {
    AuthResult result = await _provider.signInWithFacebook();
    FirebaseUser firebaseUser = result.user;
    UserResponse user = UserResponse();
    List<String> splitDisplayName = firebaseUser.displayName.split(' ');
    user.firstName = splitDisplayName[0];
    user.email = firebaseUser.email;
    user.firebaseId = firebaseUser.uid;
    if (splitDisplayName.length > 1) {
      user.lastName = splitDisplayName[1];
    }
    LoginService.storeLoginData(user);
    _controller.sink.add(LoginState(user: user));
  }

  @override
  void dispose() {
    _controller.close();
  }
}
