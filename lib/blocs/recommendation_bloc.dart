import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/class.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/recommendation.dart';
import 'package:oluko_app/repositories/class_reopository.dart';
import 'package:oluko_app/repositories/recommendation_repository.dart';

abstract class RecommendationState {}

class Loading extends RecommendationState {}

class RecommendationSuccess extends RecommendationState {
  List<Recommendation> recommendations;
  RecommendationSuccess({this.recommendations});
}

class Failure extends RecommendationState {
  final Exception exception;

  Failure({this.exception});
}

class RecommendationBloc extends Cubit<RecommendationState> {
  RecommendationBloc() : super(Loading());

  void getAll() async {
    try {
      List<Recommendation> recommendations =
          await RecommendationRepository().getAll();
      emit(RecommendationSuccess(recommendations: recommendations));
    } catch (e) {
      print(e.toString());
      emit(Failure(exception: e));
    }
  }

  void getByDestinationUser(String userId) async {
    try {
      List<Recommendation> recommendations =
          await RecommendationRepository().getByDestinationUser(userId);
      emit(RecommendationSuccess(recommendations: recommendations));
    } catch (e) {
      print(e.toString());
      emit(Failure(exception: e));
    }
  }
}
