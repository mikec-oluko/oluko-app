import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/assessment.dart';
import 'package:oluko_app/repositories/assessment_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class CarouselState {}

class CarouselLoading extends CarouselState {}

class CarouselSuccess extends CarouselState {
  final int widgetIndex;
  CarouselSuccess({this.widgetIndex});
}

class CarouselBloc extends Cubit<CarouselState> {
  CarouselBloc() : super(CarouselLoading());

  void widgetIsHiden(bool isHiden, {int widgetIndex}) {
    if (isHiden) {
      emit(CarouselSuccess(widgetIndex: widgetIndex));
    } else {
      emit( CarouselLoading());
    }
  }
}
