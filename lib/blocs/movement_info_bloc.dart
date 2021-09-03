import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/movement.dart';
import 'package:oluko_app/models/segment.dart';
import 'package:oluko_app/repositories/movement_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class MovementInfoState {}

class Loading extends MovementInfoState {}

class MovementInfoSuccess extends MovementInfoState {
  Movement movement;
  List<Movement> movementVariants;
  MovementInfoSuccess({this.movement, this.movementVariants});
}

class MovementInfoFailure extends MovementInfoState {
  final Exception exception;

  MovementInfoFailure({this.exception});
}

class MovementInfoBloc extends Cubit<MovementInfoState> {
  MovementInfoBloc() : super(Loading());

  void get(String movementId) async {
    try {
      List<Movement> movements = await MovementRepository.get(movementId);
      List<Movement> movementVariants =
          await MovementRepository.getVariants(movementId);

      emit(MovementInfoSuccess(
          movement: movements[0], movementVariants: movementVariants));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(MovementInfoFailure(exception: exception));
    }
  }
}
