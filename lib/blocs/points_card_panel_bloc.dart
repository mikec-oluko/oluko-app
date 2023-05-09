import 'package:flutter_bloc/flutter_bloc.dart';

abstract class PointsCardPanelState {}

class PointsCardPanelLoading extends PointsCardPanelState {}

class PointsCardPanelDefault extends PointsCardPanelState {}

class PointsCardPanelOpen extends PointsCardPanelState {}

class PointsCardPanelSuccess extends PointsCardPanelState {}

class PointsCardPanelFailure extends PointsCardPanelState {
  dynamic exception;
  PointsCardPanelFailure({this.exception});
}

class PointsCardPanelBloc extends Cubit<PointsCardPanelState> {
  PointsCardPanelBloc() : super(PointsCardPanelDefault());

  void emitDefaultState() {
    emit(PointsCardPanelDefault());
  }

  void openPointsCardPanel() {
    emit(PointsCardPanelOpen());
  }
}
