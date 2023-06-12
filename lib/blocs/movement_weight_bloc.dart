import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/utils/weight_helper.dart';
import 'package:oluko_app/models/weight_record.dart';
import 'package:oluko_app/repositories/course_enrollment_repository.dart';
import 'package:oluko_app/repositories/movement_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class MovementWorkoutState {}

class Loading extends MovementWorkoutState {}

class WeightRecordsSuccess extends MovementWorkoutState {
  final List<WeightRecord> records;

  WeightRecordsSuccess({this.records});
}

class WeightRecordsDispose extends MovementWorkoutState {
  final List<WeightRecord> records;

  WeightRecordsDispose({this.records});
}

class Failure extends MovementWorkoutState {
  final dynamic exception;

  Failure({this.exception});
}

class WorkoutWeightBloc extends Cubit<MovementWorkoutState> {
  WorkoutWeightBloc() : super(Loading());

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>> subscription;

  @override
  void dispose() {
    if (subscription != null) {
      subscription.cancel();
      subscription = null;
    }
    emit(WeightRecordsDispose(records: []));
  }

  Future<void> saveWeightToWorkout({@required CourseEnrollment currentCourseEnrollment, List<WorkoutWeight> workoutMovementsAndWeights}) async {
    try {
      final List<WorkoutWeight> onlyAddedWeights = _removeWeightWithoutValue(workoutMovementsAndWeights);
      await CourseEnrollmentRepository.addWeightToWorkout(currentCourseEnrollment: currentCourseEnrollment, movementsAndWeights: onlyAddedWeights);
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(Failure(exception: exception));
      rethrow;
    }
  }

  List<WorkoutWeight> _removeWeightWithoutValue(List<WorkoutWeight> workoutMovementsAndWeights) =>
      workoutMovementsAndWeights.where((record) => record.weight != null).toList();

  Future<StreamSubscription<QuerySnapshot<Map<String, dynamic>>>> getUserWeightsForWorkout(String userId) async {
    try {
      return subscription ??= MovementRepository.getUserWeightRecordsStream(userId).listen((snapshot) async {
        List<WeightRecord> weightRecords = [];
        if (snapshot.docs.isNotEmpty) {
          snapshot.docs.forEach((doc) {
            final Map<String, dynamic> _newWeightRecord = doc.data();
            weightRecords.add(WeightRecord.fromJson(_newWeightRecord));
          });
        }
        emit(WeightRecordsSuccess(records: weightRecords));
      });
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
