import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/class.dart';
import 'package:oluko_app/models/movement.dart';
import 'package:oluko_app/models/segment.dart';
import 'package:oluko_app/models/submodels/movement_submodel.dart';
import 'package:oluko_app/models/submodels/section_submodel.dart';
import 'package:oluko_app/models/submodels/segment_submodel.dart';
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

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>> subscription;
  @override
  void dispose() {
    if (subscription != null) {
      subscription.cancel();
      subscription = null;
    }
  }

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

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>> getStream() {
    subscription ??= MovementRepository.getMovementsSubscription().listen((snapshot) async {
      List<Movement> movements = [];
      snapshot.docs.forEach((doc) {
        final Map<String, dynamic> content = doc.data();
        movements.add(Movement.fromJson(content));
      });
      emit(GetAllSuccess(movements: movements));
    });
    return subscription;
  }

  Future<void> getByClass(Class classObj) async {
    try {
      emit(LoadingMovementState());
      final List<Movement> movements = [];
      for (final SegmentSubmodel segment in classObj.segments) {
        if (segment.sections != null) {
          for (final SectionSubmodel section in segment?.sections) {
            if (section.movements != null) {
              for (final MovementSubmodel movement in section.movements) {
                if (!movement.isRestTime) {
                  final List<Movement> move = await MovementRepository.get(movement.id);
                  if(move != null && move.isNotEmpty) {
                    movements.add(move.first);
                  }
                }
              }
            }
          }
        }
      }
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
