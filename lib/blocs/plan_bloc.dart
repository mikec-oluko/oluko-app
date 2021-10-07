import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/plan.dart';
import 'package:oluko_app/repositories/plan_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class PlanState {}

class Loading extends PlanState {}

class PlansSuccess extends PlanState {
  final List<Plan> plans;

  PlansSuccess({this.plans});
}

class PlanSuccess extends PlanState {
  final Plan plan;

  PlanSuccess({this.plan});
}

class Failure extends PlanState {
  final dynamic exception;

  Failure({this.exception});
}

class PlanBloc extends Cubit<PlanState> {
  PlanBloc() : super(Loading());

  void getPlans() async {
    emit(Loading());
    try {
      final List<Plan> plans = await PlanRepository().getAll();
      plans.sort((a, b) => a.title.compareTo(b.title));
      emit(PlansSuccess(plans: plans));
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
