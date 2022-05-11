// ignore_for_file: prefer_is_not_operator

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/assessment.dart';
import 'package:oluko_app/models/assessment_assignment.dart';
import 'package:oluko_app/models/submodels/questions_answers.dart';
import 'package:oluko_app/repositories/assessment_assignment_repository.dart';
import 'package:oluko_app/repositories/faq_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class FAQState {}

class FAQLoading extends FAQState {}

class FAQSuccess extends FAQState {
  List<QuestionAndAnswer> faqList;
  FAQSuccess({this.faqList});
}

class FAQFailure extends FAQState {
  final dynamic exception;

  FAQFailure({this.exception});
}

class FAQBloc extends Cubit<FAQState> {
  FAQBloc() : super(FAQLoading());

  void get() async {
    try {
      List<QuestionAndAnswer> fAQlist = await FAQRepository.getAll();
      emit(FAQSuccess(faqList: fAQlist));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(FAQFailure(exception: exception));
      rethrow;
    }
  }
}
