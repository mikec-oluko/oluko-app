import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/helpers/enum_collection.dart';

abstract class UserProgressState {}

class Loading extends UserProgressState {}

class UserProgressSuccess extends UserProgressState {
  Map<ProgressArea, int> progressAreaValues;
  UserProgressSuccess({this.progressAreaValues});
}

class UserProgressBloc extends Cubit<UserProgressState> {
  UserProgressBloc() : super(Loading());

  void getUserProgressByUserId({String userId}) {}
}

// Map<ProgressArea, int> progressAreaValues = {
//   ProgressArea.courses: valueForCourses,
//   ProgressArea.classes: valueForClasses,
//   ProgressArea.challenges: valueForChallenges,
// };
