import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/helpers/challenge_navigation.dart';

abstract class CoursePanelState {}

class LoadingCoursePanel extends CoursePanelState {}

class Failure extends CoursePanelState {
  final dynamic exception;
  Failure({this.exception});
}

class CoursePanelSuccess extends CoursePanelState {
  final Map<String, List<ChallengeNavigation>> challengeNavigations;
  CoursePanelSuccess({this.challengeNavigations});
}

class CoursePanelBloc extends Cubit<CoursePanelState> {
  CoursePanelBloc() : super(LoadingCoursePanel());

  void setPanelChallenges(List<ChallengeNavigation> challengeNavigations) {
    Map<String, List<ChallengeNavigation>> challengeCourseMap = {};
    for (var challenge in challengeNavigations) {
      String courseId = challenge.enrolledCourse.course.id;
      if (challengeCourseMap[courseId] == null) {
        challengeCourseMap[courseId] = [];
      }
      challengeCourseMap[courseId].add(challenge);
    }
    emit(CoursePanelSuccess(challengeNavigations: challengeCourseMap));
  }
}
