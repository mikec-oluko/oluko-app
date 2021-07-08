import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mvt_fitness/models/plan.dart';
import 'package:mvt_fitness/repositories/plan_repository.dart';

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
  final Exception exception;

  Failure({this.exception});
}

class PlanBloc extends Cubit<PlanState> {
  PlanBloc() : super(Loading());

  void getPlans() async {
    if (!(state is PlanSuccess)) {
      emit(Loading());
    }
    try {
      List<Plan> plans = await PlanRepository().getAll();
      plans.sort((a, b) => a.title.compareTo(b.title));
      emit(PlansSuccess(plans: plans));
    } catch (e) {
      emit(Failure(exception: e));
    }
  }
}
