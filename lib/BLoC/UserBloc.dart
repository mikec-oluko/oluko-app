import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/ApiResponse.dart';
import 'package:oluko_app/models/SignUpRequest.dart';
import 'package:oluko_app/models/SignUpResponse.dart';
import 'package:oluko_app/repositories/AuthRepository.dart';
import 'package:oluko_app/utils/AppLoader.dart';
import 'package:oluko_app/utils/AppNavigator.dart';

abstract class UserState {}

class UserSuccess extends UserState {
  final SignUpResponse user;
  UserSuccess({this.user});
}

class UserLoading extends UserState {}

class UserFailure extends UserState {
  final Exception exception;
  UserFailure({this.exception});
}

class UserBloc extends Cubit<UserState> {
  UserBloc() : super(UserLoading());

  final _repository = AuthRepository();

  Future<void> signUp(context, SignUpRequest request) async {
    ApiResponse apiResponse = await _repository.signUp(request);
    if (apiResponse.statusCode == 200) {
      SignUpResponse response = SignUpResponse.fromJson(apiResponse.data);
      AppLoader.stopLoading();
      AppNavigator().returnToHome(context);
      emit(UserSuccess(user: response));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Welcome, ${response.firstName}.'),
      ));
    } else {
      AppLoader.stopLoading();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(apiResponse.message[0]),
      ));
      emit(UserFailure(exception: Exception(apiResponse.message[0])));
    }
  }
}
