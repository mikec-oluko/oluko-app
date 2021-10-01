import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/movement.dart';
import 'package:oluko_app/models/movement_relation.dart';
import 'package:oluko_app/models/segment.dart';
import 'package:oluko_app/repositories/course_repository.dart';
import 'package:oluko_app/repositories/movement_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class MovementInfoState {}

class Loading extends MovementInfoState {}

class MovementInfoSuccess extends MovementInfoState {
  Movement movement;
  List<Movement> movementVariants;
  MovementRelation movementRelation;
  List<Course> relatedCourses;
  List<Movement> relatedMovements;
  MovementInfoSuccess(
      {this.movement, this.movementVariants, this.movementRelation, this.relatedMovements, this.relatedCourses});
}

class MovementInfoFailure extends MovementInfoState {
  final dynamic exception;

  MovementInfoFailure({this.exception});
}

class MovementInfoBloc extends Cubit<MovementInfoState> {
  MovementInfoBloc() : super(Loading());

  void get(String movementId) async {
    try {
      List<Movement> movements = await MovementRepository.get(movementId);
      List<Movement> movementVariants = await MovementRepository.getVariants(movementId);

      MovementRelation movementRelation = await MovementRepository.getRelations(movementId);

      List<List<Movement>> relatedMovementsData = await Future.wait(
          movementRelation.relatedMovements.map((movementSubmodel) => MovementRepository.get(movementSubmodel.id)));

      List<Course> relatedCourses = await Future.wait(
          movementRelation.relatedCourses.map((courseSubmodel) => CourseRepository.get(courseSubmodel.id)));

      List<Movement> relatedMovements = [];

      relatedMovementsData.forEach(
          (List<Movement> movementList) => movementList.length > 0 ? relatedMovements.add(movementList[0]) : null);

      emit(MovementInfoSuccess(
          movement: movements[0],
          movementVariants: movementVariants,
          movementRelation: movementRelation,
          relatedMovements: relatedMovements,
          relatedCourses: relatedCourses));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(MovementInfoFailure(exception: exception));
      rethrow;
    }
  }
}
