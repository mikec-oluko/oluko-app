import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/user_statistics.dart';
import 'package:oluko_app/repositories/user_statistics_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class UserStatisticsState {}

class Loading extends UserStatisticsState {}

class StatisticsSuccess extends UserStatisticsState {
  final UserStatistics userStats;

  StatisticsSuccess({this.userStats});
}

class Failure extends UserStatisticsState {
  final Exception exception;

  Failure({this.exception});
}

class UserStatisticsBloc extends Cubit<UserStatisticsState> {
  UserStatisticsBloc() : super(Loading());

  void getUserStatistics(String userId) async {
    if (!(state is StatisticsSuccess)) {
      emit(Loading());
    }
    try {
      UserStatistics userStats =
          await UserStatisticsRepository.getUserStatics(userId);
      emit(StatisticsSuccess(userStats: userStats));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(Failure(exception: exception));
    }
  }
}
