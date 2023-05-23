import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/movement.dart';
import 'package:oluko_app/repositories/movement_repository.dart';
import 'dart:async';

abstract class MaxWeightsState {}

class MaxWeightsLoading extends MaxWeightsState {}

class MaxWeightsMovements extends MaxWeightsState {
  final List<Movement> movements;
  MaxWeightsMovements({this.movements});
}

class Failure extends MaxWeightsState {
  final dynamic exception;
  Failure({this.exception});
}


class MaxWeightsBloc extends Cubit<MaxWeightsState> {
  MaxWeightsBloc() : super(MaxWeightsLoading());
  
    Future<void> getRecommendedWeightMovements() async{
      try {
        List<Movement> movements = await MovementRepository().getRecommendedWeightMovements();
        movements ?? (movements = []);
        emit(MaxWeightsMovements(movements: movements));
      } catch (e) {
        emit(Failure(exception: e));
      }
    }

}