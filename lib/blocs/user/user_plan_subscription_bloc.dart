import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/repositories/user_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class UserPlanSubscriptionState {}

class Loading extends UserPlanSubscriptionState {}

class UserIsSubscribed extends UserPlanSubscriptionState {
  UserIsSubscribed();
}

class UserIsNotSuscribed extends UserPlanSubscriptionState {
  UserIsNotSuscribed();
}

class UserChangedPlan extends UserPlanSubscriptionState {
  UserResponse userDataUpdated;
  UserChangedPlan({this.userDataUpdated});
}

class UserPlanDisposeState extends UserPlanSubscriptionState {
  UserPlanDisposeState();
}

class UserPlanSubscriptionFailed extends UserPlanSubscriptionState {
  UserPlanSubscriptionFailed({this.exception});
  final dynamic exception;
}

class UserPlanSubscriptionBloc extends Cubit<UserPlanSubscriptionState> {
  UserPlanSubscriptionBloc() : super(Loading());
  final UserRepository _userRepository = UserRepository();
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>> planSubscription;
  void dispose() {
    if (planSubscription != null) {
      planSubscription.cancel();
      planSubscription = null;
      _disposeValue();
    }
  }

  Future<StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>> getPlanSubscriptionStream({@required UserResponse loggedUser}) async {
    try {
      return planSubscription ??= _userRepository.getUserPlanStream(userId: loggedUser.id).listen((snapshot) {
        UserResponse actualUserData;
        emit(Loading());
        if (snapshot.exists) {
          final Map<String, dynamic> userDocument = snapshot.data() as Map<String, dynamic>;
          actualUserData = UserResponse.fromJson(userDocument);
        }
        if (loggedUser.currentPlan != actualUserData.currentPlan) {
          emit(UserChangedPlan(userDataUpdated: actualUserData));
        } else if (actualUserData.currentPlan <= 0) {
          emit(UserIsNotSuscribed());
        } else {
          emit(UserIsSubscribed());
        }
      });
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(UserPlanSubscriptionFailed(exception: exception));
      rethrow;
    }
  }

  _disposeValue() => emit(UserPlanDisposeState());
}
