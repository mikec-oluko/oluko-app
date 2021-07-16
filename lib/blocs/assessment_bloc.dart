import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mvt_fitness/models/assessment.dart';
import 'package:mvt_fitness/repositories/assessment_repository.dart';

abstract class AssessmentState {}

class AssessmentLoading extends AssessmentState {}

class AssessmentsSuccess extends AssessmentState {
  final List<Assessment> assessments;
  AssessmentsSuccess({this.assessments});
}

class AssessmentSuccess extends AssessmentState {
  final Assessment assessment;
  AssessmentSuccess({this.assessment});
}

class AssessmentFailure extends AssessmentState {
  final Exception exception;

  AssessmentFailure({this.exception});
}

class AssessmentBloc extends Cubit<AssessmentState> {
  AssessmentBloc() : super(AssessmentLoading());

  void get() async {
    if (!(state is AssessmentSuccess)) {
      emit(AssessmentLoading());
    }
    try {
      List<Assessment> assessments = await AssessmentRepository().getAll();
      emit(AssessmentsSuccess(assessments: assessments));
    } catch (e) {
      emit(AssessmentFailure(exception: e));
    }
  }

  void getById(String id) async {
    if (!(state is AssessmentSuccess)) {
      emit(AssessmentLoading());
    }
    try {
      Assessment assessment = await AssessmentRepository().getById(id);
      emit(AssessmentSuccess(assessment: assessment));
    } catch (e) {
      emit(AssessmentFailure(exception: e));
    }
  }
}
