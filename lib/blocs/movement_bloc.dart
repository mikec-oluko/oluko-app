import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/movement.dart';
import 'package:oluko_app/models/segment.dart';
import 'package:oluko_app/repositories/movement_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class MovementState {}

class LoadingMovementState extends MovementState {}

class GetMovementsSuccess extends MovementState {
  List<Movement> movements;
  GetMovementsSuccess({this.movements});
}

class GetAllSuccess extends MovementState {
  List<Movement> movements;
  GetAllSuccess({this.movements});
}

class Failure extends MovementState {
  final dynamic exception;

  Failure({this.exception});
}

class MovementBloc extends Cubit<MovementState> {
  MovementBloc() : super(LoadingMovementState());

  void getBySegment(Segment segment) async {
    try {
      List<Movement> movements = await MovementRepository.getBySegment(segment);
      emit(GetMovementsSuccess(movements: movements));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(Failure(exception: exception));
      rethrow;
    }
  }

  void getAll() async {
    try {
      emit(LoadingMovementState());
      final List<Movement> movements = await MovementRepository.getAll();
      emit(GetAllSuccess(movements: movements));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(Failure(exception: exception));
      rethrow;
    }
  }
}
