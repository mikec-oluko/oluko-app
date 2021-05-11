import 'dart:async';
import 'package:flutter/material.dart';
import 'package:oluko_app/models/api-response.dart';
import 'package:oluko_app/models/sign-up-request.dart';
import 'package:oluko_app/models/sign-up-response.dart';
import 'package:oluko_app/providers/sign-up-provider.dart';
import 'package:oluko_app/services/loader-service.dart';

import 'bloc.dart';

class SignUpWithEmailBloc implements Bloc {
  var _signUpResponse;
  SignUpResponse get auth => _signUpResponse;

  final _provider = SignUpProvider();
  final _controller = StreamController<SignUpResponse>.broadcast();
  Stream<SignUpResponse> get authStream => _controller.stream;

  Future<void> signUp(context, SignUpRequest request) async {
    ApiResponse apiResponse = await _provider.signUp(request);
    if (apiResponse.statusCode == 200) {
      SignUpResponse response = SignUpResponse.fromJson(apiResponse.data);
      LoaderService.stopLoading();
      _controller.sink.add(response);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Welcome, ${response.firstName}.'),
      ));
    } else {
      LoaderService.stopLoading();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(apiResponse.message),
      ));
      _controller.sink.addError(apiResponse.message);
    }
  }

  @override
  void dispose() {
    _controller.close();
  }
}
