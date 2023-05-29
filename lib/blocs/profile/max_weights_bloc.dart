import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/max_weight.dart';
import 'package:oluko_app/models/movement.dart';
import 'package:oluko_app/models/utils/weight_helper.dart';
import 'package:oluko_app/repositories/movement_repository.dart';
import 'package:oluko_app/repositories/user_repository.dart';
import 'dart:async';

import 'package:sentry_flutter/sentry_flutter.dart';

abstract class MaxWeightsState {}

class MaxWeightsLoading extends MaxWeightsState {}

class UserMaxWeights extends MaxWeightsState {
  List<MaxWeight> maxWeightRecords;
  UserMaxWeights({this.maxWeightRecords});
}

class MaxWeightsMovements extends MaxWeightsState {
  final List<Movement> movements;
  Map<String, int> maxWeightsMap;
  MaxWeightsMovements({this.movements, this.maxWeightsMap});
}

class Failure extends MaxWeightsState {
  final dynamic exception;
  Failure({this.exception});
}

class MaxWeightsBloc extends Cubit<MaxWeightsState> {
  MaxWeightsBloc() : super(MaxWeightsLoading());

  Future<void> getMaxWeightMovements(String userId) async {
    try {
      List<Movement> movements = await MovementRepository().getRecommendedWeightMovements();
      Map<String, int> maxWeightsMap = {};
      if (movements != null && movements.isNotEmpty) {
        final List<MaxWeight> userMaxWeights = await UserRepository().getMaxWeightsByUserId(userId);
        for (final movement in movements) {
          MaxWeight userWeight = userMaxWeights.firstWhere(
            (userWeight) => userWeight?.id == movement?.id,
            orElse: () => null,
          );
          maxWeightsMap[movement.id] = userWeight?.weight;
        }
      }
      movements ?? (movements = []);
      emit(MaxWeightsMovements(movements: movements, maxWeightsMap: maxWeightsMap));
    } catch (exception) {
      emit(Failure(exception: exception));
    }
  }

  setMaxWeightByUserIdAndMovementId(String userId, String movementId, int weightLBs) async {
    try {
      MaxWeight maxWeight = MaxWeight(
        id: movementId,
        weight: weightLBs,
        movementId: movementId,
      );
      UserRepository().saveMaxWeight(maxWeight, userId);
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(Failure(exception: exception));
      rethrow;
    }
  }

  emitMaxWeightsMovements(List<Movement> movements, Map<String, int> weightMap) {
    emit(MaxWeightsMovements(movements: movements, maxWeightsMap: weightMap));
  }

  Future<List<MaxWeight>> getUserMaxWeightRecords(String userId) async {
    final List<MaxWeight> userMaxWeights = await UserRepository().getMaxWeightsByUserId(userId);
    emit(UserMaxWeights(maxWeightRecords: userMaxWeights));
    return userMaxWeights;
  }

  Future<bool> setMaxWeightForSegmentMovements(String userId, List<WorkoutWeight> movementsAndWeightsToSave) async {
    try {
      await Future.wait(movementsAndWeightsToSave.map((movementMaxWeight) async {
        await setMaxWeightByUserIdAndMovementId(userId, movementMaxWeight.movementId, int.parse(movementMaxWeight.weight.toString()));
      }));
      return true;
    } catch (e) {
      return false;
    }
  }
}
