import 'dart:async';
import 'package:oluko_app/models/api-response.dart';
import 'package:oluko_app/models/login-request.dart';
import 'package:oluko_app/models/login-response.dart';
import 'package:oluko_app/providers/log-in-provider.dart';
import 'package:oluko_app/providers/user-provider.dart';

import 'bloc.dart';

class LoginBloc implements Bloc {
  var _loginResponse;
  LoginResponse get response => _loginResponse;

  final _provider = LoginProvider();
  final _userProvider = UserProvider();
  final _controller = StreamController<LoginResponse>.broadcast();
  Stream<LoginResponse> get stream => _controller.stream;

  Future<void> login(context, LoginRequest request) async {
    ApiResponse apiResponse = await _provider.login(request);
    //TODO Add get user
  }

  @override
  void dispose() {
    _controller.close();
  }
}
