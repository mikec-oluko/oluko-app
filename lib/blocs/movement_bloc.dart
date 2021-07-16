import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mvt_fitness/models/class.dart';
import 'package:mvt_fitness/models/movement.dart';
import 'package:mvt_fitness/models/segment.dart';
import 'package:mvt_fitness/repositories/movement_repository.dart';
import 'package:mvt_fitness/repositories/segment_repository.dart';

abstract class MovementState {}

class Loading extends MovementState {}

class GetMovementsSuccess extends MovementState {
  List<Movement> movements;
  GetMovementsSuccess({this.movements});
}

class Failure extends MovementState {
  final Exception exception;

  Failure({this.exception});
}

class MovementBloc extends Cubit<MovementState> {
  MovementBloc() : super(Loading());

  void getAll(Segment segment) async {
    try {
      List<Movement> movements = await MovementRepository.getAll(segment);
      emit(GetMovementsSuccess(movements: movements));
    } catch (e) {
      print(e.toString());
      emit(Failure(exception: e));
    }
  }
}
