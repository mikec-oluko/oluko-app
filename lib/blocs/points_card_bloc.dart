import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/collected_card.dart';
import 'package:oluko_app/models/enums/completion_criteria_enum.dart';
import 'package:oluko_app/models/enums/content_type_enum.dart';
import 'package:oluko_app/models/points_card.dart';
import 'package:oluko_app/repositories/collected_card_repository.dart';
import 'package:oluko_app/repositories/user_statistics_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:oluko_app/repositories/points_card_repository.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/dto/completion_dto.dart';
import 'package:oluko_app/models/user_statistics.dart';
import 'package:oluko_app/repositories/course_enrollment_repository.dart';

abstract class PointsCardState {}

class PointsCardLoading extends PointsCardState {}

class PointsCardSuccess extends PointsCardState {
  List<CollectedCard> pointsCards;
  int userPoints;
  PointsCardSuccess({this.pointsCards, this.userPoints});
}

class NewCardsCollected extends PointsCardState {
  List<PointsCard> pointsCards;
  NewCardsCollected({this.pointsCards});
}

class PointsCardFailure extends PointsCardState {
  final dynamic exception;
  PointsCardFailure({this.exception});
}

class PointsCardDefault extends PointsCardState {}

class PointsCardBloc extends Cubit<PointsCardState> {
  PointsCardBloc() : super(PointsCardLoading());

  void emitDefaultState() {
    emit(PointsCardDefault());
  }

  void getUserCards(String userId) async {
    try {
      final List<CollectedCard> collectedCards = await CollectedCardRepository.getAll(userId);
      int userPoints = 0;
      for (CollectedCard card in collectedCards) {
        userPoints += card.multiplicity * card.card.value;
      }
      emit(PointsCardSuccess(pointsCards: collectedCards, userPoints: userPoints));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(PointsCardFailure(exception: exception));
      rethrow;
    }
  }

  void updateCourseCompletionAndCheckNewCardCollected(CourseEnrollment courseEnrollment, int segmentIndex, int classIndex,
      {bool useWeigth = false, int sectionIndex, int movementIndex, double weightUsed}) async {
    try {
      List<PointsCard> newCardsCollected = [];

      final UserStatistics userStats = await UserStatisticsRepository.getUserStatics(courseEnrollment.userId);

      final Completion completionObj = await CourseEnrollmentRepository.markSegmentAsCompleted(courseEnrollment, segmentIndex, classIndex,
          useWeigth: useWeigth, sectionIndex: sectionIndex, movementIndex: movementIndex, weightUsed: weightUsed);

      final List<PointsCard> cards = await PointsCardRepository.get(courseEnrollment.userId);

      if (_userCompletedNewClassOrCourse(completionObj)) {
        for (final card in cards) {
          if (_userCompletedCardLinkedContent(card, completionObj) || _userReachedCardContentCompletion(card, completionObj, userStats)) {
            CollectedCardRepository.addCard(courseEnrollment.userId, card);
            newCardsCollected.add(card);
          }
        }
      }
      if (newCardsCollected.isNotEmpty) {
        emit(NewCardsCollected(pointsCards: newCardsCollected));
      }
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(PointsCardFailure(exception: exception));
      rethrow;
    }
  }

  bool _userCompletedNewClassOrCourse(Completion completionObj) {
    return completionObj.completedClassId != null || completionObj.completedCourseId != null;
  }

  bool _userCompletedCardLinkedContent(PointsCard card, Completion completionObj) {
    return _cardCriteriaIsByLinkedContent(card) &&
        (_cardClassMatchesCompletedClass(card, completionObj) || _cardCourseMatchesCompletedCourse(card, completionObj));
  }

  bool _cardClassMatchesCompletedClass(PointsCard card, Completion completionObj) {
    return _cardContentIsClass(card) && card.contentId == completionObj.completedClassId;
  }

  bool _cardCourseMatchesCompletedCourse(PointsCard card, Completion completionObj) {
    return _cardContentIsCourse(card) && card.contentId == completionObj.completedCourseId;
  }

  bool _cardCriteriaIsByLinkedContent(PointsCard card) {
    return card.completionCriteria == CompletionCriteriaEnum.linkedContent;
  }

  bool _userReachedCardContentCompletion(PointsCard card, Completion completionObj, UserStatistics userStats) {
    return _cardCriteriaIsByCompletedContent(card) && _userReachedCardClassesCompletion(card, completionObj, userStats) ||
        _userReachedCardCoursesCompletion(card, completionObj, userStats);
  }

  bool _cardCriteriaIsByCompletedContent(PointsCard card) {
    return card.completionCriteria == CompletionCriteriaEnum.completedContent;
  }

  bool _userReachedCardClassesCompletion(PointsCard card, Completion completionObj, UserStatistics userStats) {
    return completionObj.completedClassId != null && _cardContentIsClass(card) && (userStats.completedClasses + 1) == card.completion;
  }

  bool _userReachedCardCoursesCompletion(PointsCard card, Completion completionObj, UserStatistics userStats) {
    return completionObj.completedCourseId != null && _cardContentIsCourse(card) && (userStats.completedCourses + 1) == card.completion;
  }

  bool _cardContentIsClass(PointsCard card) {
    return card.contentType == ContentTypeEnum.classObj;
  }

  bool _cardContentIsCourse(PointsCard card) {
    return card.contentType == ContentTypeEnum.course;
  }
}
