import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/assessment.dart';
import 'package:oluko_app/repositories/assessment_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class CarrouselState {}

class CarrouselLoading extends CarrouselState {}

class CarrouselSuccess extends CarrouselState {
  final int widgetIndex;
  final double opacity;
  CarrouselSuccess({this.widgetIndex, this.opacity});
}

class CarrouselBloc extends Cubit<CarrouselState> {
  CarrouselBloc() : super(CarrouselLoading());

  void widgetIsHiden(bool isHiden, int widgetIndex) {
    if (isHiden) {
      emit(CarrouselSuccess(widgetIndex: widgetIndex, opacity: 1));
    } else {
      emit(CarrouselLoading());
    }
  }
}
