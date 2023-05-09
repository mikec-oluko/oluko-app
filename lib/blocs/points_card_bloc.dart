import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/points_card.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:oluko_app/repositories/points_card_repository.dart';

abstract class PointsCardState {}

class PointsCardLoading extends PointsCardState {}

class PointsCardSuccess extends PointsCardState {
  List<PointsCard> pointsCards;
  PointsCardSuccess({this.pointsCards});
}

class PointsCardFailure extends PointsCardState {
  final dynamic exception;
  PointsCardFailure({this.exception});
}

class PointsCardBloc extends Cubit<PointsCardState> {
  PointsCardBloc() : super(PointsCardLoading());

  void get(String userId) async {
    try {
      final List<PointsCard> cards = await PointsCardRepository.get(userId);
      emit(PointsCardSuccess(pointsCards: cards));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(PointsCardFailure(exception: exception));
      rethrow;
    }
  }
}
