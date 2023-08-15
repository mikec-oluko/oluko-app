import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/recommendation.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/repositories/recommendation_repository.dart';
import 'package:oluko_app/repositories/user_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class RecommendationState {}

class Loading extends RecommendationState {}

class RecommendationSuccess extends RecommendationState {
  List<Recommendation> recommendations;
  Map<String, List<UserResponse>> recommendationsByUsers;
  RecommendationSuccess({this.recommendations, this.recommendationsByUsers});
}

class Failure extends RecommendationState {
  final dynamic exception;

  Failure({this.exception});
}

class RecommendationBloc extends Cubit<RecommendationState> {
  RecommendationBloc() : super(Loading());

  void getAll() async {
    try {
      List<Recommendation> recommendations = await RecommendationRepository().getAll();
      emit(RecommendationSuccess(recommendations: recommendations));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(Failure(exception: exception));
      rethrow;
    }
  }

  void removeRecommendedCourse(String userId, String courseId) {
    try {
      RecommendationRepository().removeRecomendedCourse(userId, courseId);
    } catch (e) {
      return;
    }
  }

  void getByDestinationUser(String userId) async {
    try {
      List<Recommendation> recommendations = await RecommendationRepository().getByDestinationUser(userId);
      emit(RecommendationSuccess(recommendations: recommendations));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(Failure(exception: exception));
      rethrow;
    }
  }

  void getRecommendedCoursesByUser(String userId) async {
    try {
      List<Recommendation> recommendations = await RecommendationRepository().getByDestinationUser(userId);

      //Filter recommendations by Course recommendations
      List<Recommendation> courseRecommendations =
          recommendations.where((Recommendation element) => element.entityType == RecommendationEntityType.course && element.isDeleted != true).toList();

      //Get a Map of Courses and their recommender user ids (Map<CourseId, List<UserId>>)
      Map<String, List<String>> coursesRecommendedByUserIds = _getCoursesRecommendedByUsers(courseRecommendations);

      //Get a List of unique recommender user ids
      List<String> recommendationUserIds = courseRecommendations.map((e) => e.originUserId).toList();
      recommendationUserIds = _removeDuplicates(recommendationUserIds);

      //Retrieve user information for recommenders to get their avatars
      //TODO Repository method to only retrieve basic & public information from users
      List<UserResponse> recommendationUsers = await Future.wait(recommendationUserIds.map((String userId) async {
        return UserRepository().getById(userId);
      }).toList());

      //Get a Map of Courses and their recommender users (Map<CourseId, List<UserResponse>)
      Map<String, List<UserResponse>> coursesRecommendedByUsers = {};
      coursesRecommendedByUserIds.entries.forEach((MapEntry<String, List<String>> coursesRecommendedByIdsEntry) {
        MapEntry<String, List<UserResponse>> coursesRecommendedByUserEntry = MapEntry(coursesRecommendedByIdsEntry.key,
            coursesRecommendedByIdsEntry.value.map((String userId) => recommendationUsers.where((user) => user.id == userId).toList()[0]).toList());
        coursesRecommendedByUsers[coursesRecommendedByUserEntry.key] = coursesRecommendedByUserEntry.value;
      });

      emit(RecommendationSuccess(recommendations: recommendations, recommendationsByUsers: coursesRecommendedByUsers));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(Failure(exception: exception));
      rethrow;
    }
  }

  Map<String, List<String>> _getCoursesRecommendedByUsers(List<Recommendation> recommendations) {
    Map<String, List<String>> recommendationsByCourses = {};
    recommendations.forEach((Recommendation recommendation) {
      if (recommendationsByCourses[recommendation.entityId] == null) {
        recommendationsByCourses[recommendation.entityId] = [recommendation.originUserId];
      } else {
        recommendationsByCourses[recommendation.entityId].add(recommendation.originUserId);
      }
    });

    return recommendationsByCourses;
  }

  List<String> _removeDuplicates(List<String> items) {
    return items.toSet().toList();
  }
}
