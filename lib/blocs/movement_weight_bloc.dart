import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/plan.dart';
import 'package:oluko_app/models/utils/weight_helper.dart';
import 'package:oluko_app/repositories/course_enrollment_repository.dart';
import 'package:oluko_app/repositories/plan_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class MovementWorkoutState {}

class Loading extends MovementWorkoutState {}

// class PlansSuccess extends MovementWorkoutState {
//   final List<Plan> plans;

//   PlansSuccess({this.plans});
// }

// class PlanSuccess extends MovementWorkoutState {
//   final Plan plan;

//   PlanSuccess({this.plan});
// }

class Failure extends MovementWorkoutState {
  final dynamic exception;

  Failure({this.exception});
}

class WorkoutWeightBloc extends Cubit<MovementWorkoutState> {
  WorkoutWeightBloc() : super(Loading());

  void saveWeightToWorkout({String courseEnrollmentId, List<WorkoutWeight> workoutMovementsAndWeights}) async {
    try {
      await CourseEnrollmentRepository.addWeightToWorkout(courseEnrollmentId: courseEnrollmentId, movementsAndWeights: workoutMovementsAndWeights);
      //emit(MarkSegmentSuccess());
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(Failure(exception: exception));
      rethrow;
    }
  }

  void getWeightsForWorkouts() async {
    try {} catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(Failure(exception: exception));
      rethrow;
    }
  }
}
