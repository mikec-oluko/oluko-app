import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:oluko_app/models/api-response.dart';
import 'package:oluko_app/models/login-request.dart';
import 'package:oluko_app/models/states/login-state.dart';
import 'package:oluko_app/models/user-response.dart';
import 'package:oluko_app/repositories/AuthRepository.dart';
import 'package:oluko_app/repositories/UserRepository.dart';
import 'package:oluko_app/utils/AppLoader.dart';
import 'package:oluko_app/utils/AppMessages.dart';
import 'Bloc.dart';

class LoginBloc implements Bloc {
  var _loginResponse;
  UserResponse get response => _loginResponse;

  final _repository = AuthRepository();
  final _userProvider = UserRepository();
  final _controller = StreamController<LoginState>.broadcast();
  Stream<LoginState> get stream => _controller.stream;

  Future<void> login(context, LoginRequest request) async {
    ApiResponse apiResponse = await _repository.login(request);
    if (apiResponse.statusCode != 200) {
      AppLoader.stopLoading();
      AppMessages.showSnackbar(context, apiResponse.message[0]);
      _controller.sink.addError(LoginState(
          error: apiResponse.error, errorMessages: apiResponse.message));
      return;
    }
    UserResponse user = await _userProvider.get(request.email);
    AuthRepository.storeLoginData(user);
    AppLoader.stopLoading();
    _controller.sink.add(LoginState(user: user));
  }

  Future<void> loginWithGoogle(context) async {
    AuthResult result = await _repository.signInWithGoogle();
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
    _controller.sink.add(LoginState(user: user));
  }

  Future<void> loginWithFacebook(context) async {
    AuthResult result = await _repository.signInWithFacebook();
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
    _controller.sink.add(LoginState(user: user));
  }

  @override
  void dispose() {
    _controller.close();
  }
}
