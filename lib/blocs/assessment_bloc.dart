import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/assessment.dart';
import 'package:oluko_app/repositories/assessment_repository.dart';

abstract class AssessmentState {}

class AssessmentLoading extends AssessmentState {}

class AssessmentSuccess extends AssessmentState {
  final List<Assessment> values;
  AssessmentSuccess({this.values});
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
      emit(AssessmentSuccess(values: assessments));
    } catch (e) {
      emit(AssessmentFailure(exception: e));
    }
  }

  void getById(String id) async {
    if (!(state is AssessmentSuccess)) {
      emit(AssessmentLoading());
    }
    try {
      List<Assessment> assessments = await AssessmentRepository().getById(id);
      emit(AssessmentSuccess(values: assessments));
    } catch (e) {
      emit(AssessmentFailure(exception: e));
    }
  }
}
