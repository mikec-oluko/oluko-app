import 'dart:async';
import 'package:flutter/material.dart';
import 'package:oluko_app/models/api-response.dart';
import 'package:oluko_app/models/sign-up-request.dart';
import 'package:oluko_app/models/sign-up-response.dart';
import 'package:oluko_app/providers/AuthRepository.dart';
import 'package:oluko_app/utils/AppLoader.dart';

import 'bloc.dart';

class SignUpWithEmailBloc implements Bloc {
  var _signUpResponse;
  SignUpResponse get auth => _signUpResponse;

  final _repository = AuthRepository();
  final _controller = StreamController<SignUpResponse>.broadcast();
  Stream<SignUpResponse> get authStream => _controller.stream;

  Future<void> signUp(context, SignUpRequest request) async {
    ApiResponse apiResponse = await _repository.signUp(request);
    if (apiResponse.statusCode == 200) {
      SignUpResponse response = SignUpResponse.fromJson(apiResponse.data);
      AppLoader.stopLoading();
      _controller.sink.add(response);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Welcome, ${response.firstName}.'),
      ));
    } else {
      AppLoader.stopLoading();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(apiResponse.message[0]),
      ));
      _controller.sink.addError(apiResponse.message[0]);
    }
  }

  @override
  void dispose() {
    _controller.close();
  }
}
