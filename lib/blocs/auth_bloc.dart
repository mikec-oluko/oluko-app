import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/blocs/assessment_assignment_bloc.dart';
import 'package:oluko_app/blocs/assessment_bloc.dart';
import 'package:oluko_app/blocs/challenge/challenge_bloc.dart';
import 'package:oluko_app/blocs/challenge/upcoming_challenge_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_assignment_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_audio_messages_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_media_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_video_message_bloc.dart';
import 'package:oluko_app/blocs/course/course_friend_recommended_bloc.dart';
import 'package:oluko_app/blocs/course/course_liked_courses_bloc.dart';
import 'package:oluko_app/blocs/course/course_subscription_bloc.dart';
import 'package:oluko_app/blocs/course_category_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_bloc.dart';
import 'package:oluko_app/blocs/notification_bloc.dart';
import 'package:oluko_app/blocs/project_configuration_bloc.dart';
import 'package:oluko_app/blocs/story_list_bloc.dart';
import 'package:oluko_app/blocs/subscription_content_bloc.dart';
import 'package:oluko_app/blocs/user/user_plan_subscription_bloc.dart';
import 'package:oluko_app/blocs/user_progress_stream_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/helpers/permissions.dart';
import 'package:oluko_app/models/assessment_assignment.dart';
import 'package:oluko_app/models/dto/api_response.dart';
import 'package:oluko_app/models/dto/forgot_password_dto.dart';
import 'package:oluko_app/models/dto/login_request.dart';
import 'package:oluko_app/models/sign_up_request.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/repositories/assessment_assignment_repository.dart';
import 'package:oluko_app/repositories/auth_repository.dart';
import 'package:oluko_app/repositories/user_repository.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/services/global_service.dart';
import 'package:oluko_app/services/push_notification_service.dart';
import 'package:oluko_app/utils/app_loader.dart';
import 'package:oluko_app/utils/app_messages.dart';
import 'package:oluko_app/utils/app_navigator.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/user_utils.dart';
import 'package:oluko_app/blocs/coach/coach_interaction_timeline_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_mentored_videos_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_recommendations_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_request_stream_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_review_pending_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_sent_videos_bloc.dart';
// import 'package:oluko_app/blocs/course/course_subscription_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_list_stream_bloc.dart';

abstract class AuthState {}

class AuthSuccess extends AuthState {
  final UserResponse user;
  final User firebaseUser;
  AuthSuccess({this.user, this.firebaseUser});
}

class AuthFailure extends AuthState {
  final dynamic exception;
  AuthFailure({this.exception});
}

class AuthLoading extends AuthState {}

class AuthResetPassSent extends AuthState {}

class AuthResetPassLoading extends AuthState {}

class AuthGuest extends AuthState {}

class AuthBloc extends Cubit<AuthState> {
  AuthBloc() : super(AuthLoading()) {
    checkCurrentUser();
  }

  final _authRepository = AuthRepository();
  final _userRepository = UserRepository();
  final GlobalService _globalService = GlobalService();

  Color snackBarBackground = const Color.fromRGBO(248, 248, 248, 1);

  Future<void> login(BuildContext context, LoginRequest request) async {
    if (!_globalService.hasInternetConnection) {
      AppMessages.clearAndShowSnackbarTranslated(context, 'noInternetConnectionHeaderText');
      return;
    }
    if (request.email == null && request.userName.isEmpty && request.password.isEmpty) {
      AppMessages.clearAndShowSnackbarTranslated(context, 'invalidUsernameOrPw');
      return;
    }

    if (request.email == null && request.userName.isEmpty) {
      AppMessages.clearAndShowSnackbarTranslated(context, 'emailUsernameRequired');
      return;
    }

    if (request.password.isEmpty) {
      AppMessages.clearAndShowSnackbarTranslated(context, 'passwordRequired');
      return;
    }
    AppLoader.startLoading(context);
    final ApiResponse apiResponse = await _authRepository.login(request);
    AppLoader.stopLoading();
    if (apiResponse.statusCode != 200) {
      //TODO: response should bring key apiResponse.message
      AppMessages.showSnackbar(context, OlukoLocalizations.of(context).find('invalidUsernameOrPw'));
      if (request.password.contains(' ')) {
        AppMessages.showSnackbar(
          context,
          OlukoLocalizations.of(context).find('passwordSpaceWarning'),
          backgroundColor: snackBarBackground,
          textColor: Colors.black,
        );
      }
      emit(AuthFailure(exception: Exception(apiResponse.message)));
      return;
    }
    UserResponse user;
    if (request.email == null) {
      user = await _userRepository.getByUsername(request.userName);
    } else {
      user = await _userRepository.get(request.email);
    }

    final firebaseUser = FirebaseAuth.instance.currentUser;
    if ((firebaseUser?.emailVerified != null && !firebaseUser.emailVerified) || (firebaseUser?.emailVerified == null && true)) {
      //TODO: trigger to send another email
      await firebaseUser?.updateEmail(user.email);
      FirebaseAuth.instance.signOut();
      AppMessages.clearAndShowSnackbarTranslated(context, 'pleaseCheckYourEmail');
      emit(AuthGuest());
    } else {
      AuthRepository().storeLoginData(user);
      UserRepository().updateLastTimeOpeningApp(user);
      if (user.currentPlan < 0 || user.currentPlan == null) {
        if (Platform.isIOS || Platform.isMacOS) {
          AppMessages.clearAndShowSnackbarTranslated(context, 'selectASubscription');
          AppNavigator().goToSubscriptionsFromRegister(context);
          emit(AuthSuccess(user: user, firebaseUser: firebaseUser));
        } else {
          AppMessages.clearAndShowSnackbarTranslated(context, 'pleaseSubscribe');
        }
        return;
      } else {
        if (firebaseUser != null) {
          AppMessages.clearAndShowSnackbar(context, '${OlukoLocalizations.get(context, 'welcome')}, ${user.firstName}');
          if (user.firstLoginAt == null) {
            await storeFirstsUserInteraction(userIteraction: UserInteractionEnum.login);
          }
          emit(AuthSuccess(user: user, firebaseUser: firebaseUser));
          navigateToNextScreen(context, firebaseUser.uid);
        }
      }
    }
  }

  void navigateToNextScreen(BuildContext context, String userId) async {
    await PushNotificationService.initializePushNotifications(context, userId);
    if (await UserUtils.isFirstTime()) {
      await Permissions.askForPermissions();
    }
    UserUtils.checkFirstTimeAndUpdate();
    await AppNavigator().returnToHome(context);
  }

  Future<void> loginWithGoogle(BuildContext context) async {
    if (!_globalService.hasInternetConnection) {
      AppMessages.clearAndShowSnackbarTranslated(context, 'noInternetConnectionHeaderText');
      return;
    }
    emit(AuthLoading());
    UserCredential result;
    try {
      try {
        result = await _authRepository.signInWithGoogle();
      } on FirebaseAuthException {
        AppMessages.clearAndShowSnackbar(
          context,
          OlukoLocalizations.get(context, 'accountAlreadyExistsWithThisEmailUsingADifferentProvider'),
        );
        rethrow;
      } catch (error) {
        AppMessages.clearAndShowSnackbar(context, OlukoLocalizations.get(context, 'errorOccurred'));
        rethrow;
      }
      if (result == null) {
        FirebaseAuth.instance.signOut();
        AppMessages.clearAndShowSnackbar(context, OlukoLocalizations.get(context, 'errorOccurred'));
        emit(AuthGuest());
        return;
      }
      final User firebaseUser = result.user;
      final UserResponse userResponse = await UserRepository().get(firebaseUser?.email);

      //If there is no associated user for this account
      if (userResponse == null) {
        FirebaseAuth.instance.signOut();
        AppMessages.clearAndShowSnackbar(context, OlukoLocalizations.get(context, 'userForThisAccountNotFound'));
        emit(AuthGuest());
        return;
      }

      UserRepository().updateLastTimeOpeningApp(userResponse);
      AuthRepository().storeLoginData(userResponse);
      if (firebaseUser != null) {
        emit(AuthSuccess(user: userResponse, firebaseUser: firebaseUser));
        if (userResponse.currentPlan < 0 || userResponse.currentPlan == null) {
          AppMessages.clearAndShowSnackbarTranslated(context, 'selectASubscription');
          AppNavigator().goToSubscriptionsFromRegister(context);
          emit(AuthSuccess(user: userResponse, firebaseUser: firebaseUser));
          return;
        }
        emit(AuthSuccess(user: userResponse, firebaseUser: firebaseUser));
        AppMessages.clearAndShowSnackbar(
          context,
          '${OlukoLocalizations.get(context, 'welcome')}, ${userResponse?.firstName ?? userResponse?.username}',
        );
        navigateToNextScreen(context, firebaseUser.uid);
      }
      // ignore: avoid_catching_errors
    } on NoSuchMethodError {
      if (OlukoNeumorphism.isNeumorphismDesign) {
        Navigator.pushNamed(context, routeLabels[RouteEnum.loginNeumorphic]);
      } else {
        Navigator.pushNamed(context, routeLabels[RouteEnum.signUp]);
      }
    }
  }

  Future<void> loginWithFacebook(BuildContext context) async {
    UserCredential result;
    try {
      result = await _authRepository.signInWithFacebook();
    } on FirebaseAuthException {
      AppMessages.clearAndShowSnackbar(
        context,
        OlukoLocalizations.get(context, 'accountAlreadyExistsWithThisEmailUsingADifferentProvider'),
      );
      rethrow;
    } catch (error) {
      AppMessages.clearAndShowSnackbar(context, OlukoLocalizations.get(context, 'errorOccurred'));
      rethrow;
    }
    if (result == null) {
      FirebaseAuth.instance.signOut();
      AppMessages.clearAndShowSnackbar(context, OlukoLocalizations.get(context, 'errorOccurred'));
      emit(AuthGuest());
      return;
    }

    if (result != null) {
      final User firebaseUser = result.user;
      final UserResponse user = await UserRepository().get(firebaseUser.email);

      //If there is no associated user for this account
      if (user == null) {
        FirebaseAuth.instance.signOut();
        AppMessages.clearAndShowSnackbar(context, OlukoLocalizations.get(context, 'userForThisAccountNotFound'));
        emit(AuthGuest());
        return;
      }

      UserRepository().updateLastTimeOpeningApp(user);
      AuthRepository().storeLoginData(user);
      if (user.currentPlan < 0 || user.currentPlan == null) {
        AppMessages.clearAndShowSnackbarTranslated(context, 'selectASubscription');
        AppNavigator().goToSubscriptionsFromRegister(context);
        emit(AuthSuccess(user: user, firebaseUser: firebaseUser));
        return;
      }

      emit(AuthSuccess(user: user, firebaseUser: firebaseUser));
      navigateToNextScreen(context, firebaseUser.uid);
    }
  }

  Future<void> loginWithApple(BuildContext context) async {
    if (!_globalService.hasInternetConnection) {
      AppMessages.clearAndShowSnackbarTranslated(context, 'noInternetConnectionHeaderText');
      return;
    }
    emit(AuthLoading());
    User result;
    try {
      try {
        result = await _authRepository.signInWithApple();
      } on FirebaseAuthException catch (error) {
        AppMessages.clearAndShowSnackbar(context, OlukoLocalizations.get(context, 'accountAlreadyExistsWithThisEmailUsingADifferentProvider'));
        rethrow;
      } catch (error) {
        AppMessages.clearAndShowSnackbar(context, OlukoLocalizations.get(context, 'errorOccurred'));
        rethrow;
      }
      if (result == null) {
        FirebaseAuth.instance.signOut();
        AppMessages.clearAndShowSnackbar(context, OlukoLocalizations.get(context, 'errorOccurred'));
        emit(AuthGuest());
        return;
      }
      UserResponse userResponse = await UserRepository().get(result?.email);

      //If there is no associated user for this account
      if (userResponse == null) {
        FirebaseAuth.instance.signOut();
        AppMessages.clearAndShowSnackbar(context, OlukoLocalizations.get(context, 'userForThisAccountNotFound'));
        emit(AuthGuest());
        return;
      }
      
      AuthRepository().storeLoginData(userResponse);
      UserRepository().updateLastTimeOpeningApp(userResponse);

      if (userResponse.currentPlan < 0 || userResponse.currentPlan == null) {
        AppMessages.clearAndShowSnackbarTranslated(context, 'selectASubscription');
        AppNavigator().goToSubscriptionsFromRegister(context);
        emit(AuthSuccess(user: userResponse, firebaseUser: result));
        return;
      }
      if (result != null) {
        emit(AuthSuccess(user: userResponse, firebaseUser: result));
        AppMessages.clearAndShowSnackbar(context, '${OlukoLocalizations.get(context, 'welcome')}, ${userResponse?.firstName ?? userResponse?.username}');
        navigateToNextScreen(context, result.uid);
      }
      // ignore: avoid_catching_errors
    } on NoSuchMethodError catch (e) {
      if (OlukoNeumorphism.isNeumorphismDesign) {
        Navigator.pushNamed(context, routeLabels[RouteEnum.loginNeumorphic]);
      } else {
        Navigator.pushNamed(context, routeLabels[RouteEnum.signUp]);
      }
    }
  }

  Future<UserResponse> retrieveLoginData() {
    return AuthRepository().retrieveLoginData();
  }

  Future<bool> storeUpdatedLoginData(UserChangedPlan userWithPlanChanged) async {
    if (userWithPlanChanged.userDataUpdated != null && userWithPlanChanged.userDataUpdated is UserResponse) {
      return AuthRepository().storeLoginData(userWithPlanChanged.userDataUpdated);
    } else {
      return false;
    }
  }

  Future<void> storeFirstsUserInteraction({UserInteractionEnum userIteraction}) async {
    final UserResponse currentUser = await _authRepository.retrieveLoginData();
    final loggedUser = AuthRepository.getLoggedUser();
    Timestamp userInteractionDate = Timestamp.now();
    final UserResponse userStoredFirstLogin = await _userRepository.saveUserFirstIteractions(currentUser, userInteractionDate, userIteraction);
    _authRepository.storeLoginData(userStoredFirstLogin);
    emit(AuthSuccess(user: userStoredFirstLogin, firebaseUser: loggedUser));
  }

  void updateAuthSuccess(UserResponse userResponse, User firebaseUser) {
    emit(AuthSuccess(user: userResponse, firebaseUser: firebaseUser));
  }

  static Future<User> checkCurrentUserStatic() async {
    final loggedUser = AuthRepository.getLoggedUser();
    final userData = await AuthRepository().retrieveLoginData();
    if (loggedUser != null && userData != null) {
      return loggedUser;
    } else {
      return null;
    }
  }

  Future<User> checkCurrentUser() async {
    final loggedUser = AuthRepository.getLoggedUser();
    final userData = await AuthRepository().retrieveLoginData();
    if (loggedUser != null && userData != null) {
      emit(AuthSuccess(user: userData, firebaseUser: loggedUser));
    } else {
      emit(AuthGuest());
    }
    return loggedUser;
  }

  Future<void> logout(BuildContext context, {bool userDeleted = false}) async {
    _globalService.videoProcessing = false;

    final success = await AuthRepository().removeLoginData();
    if (success == true) {
      try {
        BlocProvider.of<CoachMentoredVideosBloc>(context).dispose();
        BlocProvider.of<CoachRecommendationsBloc>(context).dispose();
        BlocProvider.of<CoachTimelineItemsBloc>(context).dispose();
        BlocProvider.of<StoryListBloc>(context).dispose();
        BlocProvider.of<UserProgressStreamBloc>(context).dispose();
        BlocProvider.of<CoachSentVideosBloc>(context).dispose();
        BlocProvider.of<CoachReviewPendingBloc>(context).dispose();
        BlocProvider.of<CourseEnrollmentListStreamBloc>(context).dispose();
        BlocProvider.of<ChallengeStreamBloc>(context).dispose();
        BlocProvider.of<CourseSubscriptionBloc>(context).dispose();
        BlocProvider.of<CourseCategoryBloc>(context).dispose();
        BlocProvider.of<CoachRequestStreamBloc>(context).dispose();
        BlocProvider.of<NotificationBloc>(context).dispose();
        BlocProvider.of<CoachMediaBloc>(context).dispose();
        BlocProvider.of<CoachAudioMessageBloc>(context).dispose();
        BlocProvider.of<ProjectConfigurationBloc>(context).dispose();
        BlocProvider.of<CoachVideoMessageBloc>(context).dispose();
        BlocProvider.of<CourseRecommendedByFriendBloc>(context).dispose();
        BlocProvider.of<LikedCoursesBloc>(context).dispose();
        BlocProvider.of<CoachAssignmentBloc>(context).dispose();
        BlocProvider.of<AssessmentAssignmentBloc>(context).dispose();
        BlocProvider.of<AssessmentBloc>(context).dispose();
        BlocProvider.of<UserPlanSubscriptionBloc>(context).dispose();
        BlocProvider.of<CourseEnrollmentBloc>(context).dispose();
        BlocProvider.of<UpcomingChallengesBloc>(context).dispose();
      } catch (e) {}

      if (Platform.isIOS || Platform.isMacOS) {
        BlocProvider.of<SubscriptionContentBloc>(context).dispose();
      }

      if (OlukoNeumorphism.isNeumorphismDesign) {
        Navigator.pushNamedAndRemoveUntil(context, routeLabels[RouteEnum.loginNeumorphic], (route) => false,
            arguments: {'dontShowWelcomeTest': true, 'userDeleted': userDeleted});
      } else {
        Navigator.pushNamedAndRemoveUntil(context, routeLabels[RouteEnum.signUp], (route) => false);
      }
      emit(AuthGuest());
    }
  }

  Future<void> sendPasswordResetEmail(BuildContext context, ForgotPasswordDto forgotPasswordDto) async {
    if (forgotPasswordDto.email == null || forgotPasswordDto.email == '') {
      AppMessages.clearAndShowSnackbar(context, OlukoLocalizations.get(context, 'enterEmail'));
      return;
    }
    emit(AuthResetPassLoading());
    try {
      await AuthRepository().sendPasswordResetEmail(forgotPasswordDto);
      AppMessages.clearAndShowSnackbar(context, OlukoLocalizations.get(context, 'pleaseCheckYourEmailForInstructions'));
      emit(AuthResetPassSent());
    } catch (e) {
      AppMessages.clearAndShowSnackbar(context, OlukoLocalizations.get(context, 'wrongEmailFormat'));
    }
  }

  // String getRandString(int len) {
  //   var random = Random.secure();
  //   var values = List<int>.generate(len, (i) => random.nextInt(255));
  //   return base64UrlEncode(values);
  // }

  Future<UserResponse> _signUpWithSSO(User firebaseUser) async {
    final List<String> splitDisplayName = firebaseUser.displayName.split(' ');
    final SignUpRequest signUpRequest = SignUpRequest(
      email: firebaseUser.email,
      firstName: splitDisplayName[0],
      lastName: splitDisplayName[1],
      projectId: GlobalConfiguration().getString('projectId'),
    );
    final UserResponse response = await UserRepository().createSSO(signUpRequest);
    return response;
  }
}
