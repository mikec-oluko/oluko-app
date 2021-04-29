import 'dart:async';
import 'package:oluko_app/models/sign-up-request.dart';
import 'package:oluko_app/models/sign-up-response.dart';
import 'package:oluko_app/providers/sign-up-provider.dart';

import 'bloc.dart';

class SignUpWithEmailBloc implements Bloc {
  var _signUpResponse;
  SignUpResponse get auth => _signUpResponse;

  final _provider = SignUpProvider();
  final _controller = StreamController<SignUpResponse>();
  Stream<SignUpResponse> get authStream => _controller.stream;

  Future<void> signUp(SignUpRequest request) async {
    SignUpResponse response = await _provider.signUp(request);
    _controller.sink.add(response);
  }

  @override
  void dispose() {
    _controller.close();
  }
}
