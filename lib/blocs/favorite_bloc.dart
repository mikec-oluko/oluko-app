import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/favorite.dart';
import 'package:oluko_app/repositories/favorite_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class FavoriteState {}

class Loading extends FavoriteState {}

class FavoriteSuccess extends FavoriteState {
  List<Favorite> favorites;
  FavoriteSuccess({this.favorites});
}

class Failure extends FavoriteState {
  final dynamic exception;

  Failure({this.exception});
}

class FavoriteBloc extends Cubit<FavoriteState> {
  FavoriteBloc() : super(Loading());

  void getAll() async {
    try {
      List<Favorite> favorites = await FavoriteRepository().getAll();
      emit(FavoriteSuccess(favorites: favorites));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(Failure(exception: exception));
      rethrow;
    }
  }

  void getByUser(String userId) async {
    try {
      List<Favorite> favorites = await FavoriteRepository().getByUserId(userId);
      emit(FavoriteSuccess(favorites: favorites));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(Failure(exception: exception));
      rethrow;
    }
  }
}
