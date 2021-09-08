import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/assessment.dart';
import 'package:oluko_app/repositories/assessment_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

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
  final dynamic exception;

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
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(AssessmentFailure(exception: exception));
      rethrow;
    }
  }

  void getById(String id) async {
    if (!(state is AssessmentSuccess)) {
      emit(AssessmentLoading());
    }
    try {
      Assessment assessment = await AssessmentRepository().getById(id);
      emit(AssessmentSuccess(assessment: assessment));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(AssessmentFailure(exception: exception));
      rethrow;
    }
  }
}
