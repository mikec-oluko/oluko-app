import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/blocs/challenge/challenge_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_media_bloc.dart';
import 'package:oluko_app/blocs/course_category_bloc.dart';
import 'package:oluko_app/blocs/notification_bloc.dart';
import 'package:oluko_app/blocs/story_list_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/permissions.dart';
import 'package:oluko_app/models/assessment_assignment.dart';
import 'package:oluko_app/models/dto/api_response.dart';
import 'package:oluko_app/models/dto/login_request.dart';
import 'package:oluko_app/models/sign_up_request.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/repositories/assessment_assignment_repository.dart';
import 'package:oluko_app/repositories/auth_repository.dart';
import 'package:oluko_app/repositories/user_repository.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/services/global_service.dart';
import 'package:oluko_app/utils/app_loader.dart';
import 'package:oluko_app/utils/app_messages.dart';
import 'package:oluko_app/utils/app_navigator.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'coach/coach_interaction_timeline_bloc.dart';
import 'coach/coach_mentored_videos_bloc.dart';
import 'coach/coach_recommendations_bloc.dart';
import 'coach/coach_request_bloc.dart';
import 'coach/coach_request_stream_bloc.dart';
import 'coach/coach_review_pending_bloc.dart';
import 'coach/coach_sent_videos_bloc.dart';
import 'course/course_subscrption_bloc.dart';
import 'course_enrollment/course_enrollment_list_bloc.dart';
import 'course_enrollment/course_enrollment_list_stream_bloc.dart';

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

class AuthGuest extends AuthState {}

class AuthBloc extends Cubit<AuthState> {
  AuthBloc() : super(AuthLoading()) {
    checkCurrentUser();
  }

  final _authRepository = AuthRepository();
  final _userRepository = UserRepository();
  GlobalService _globalService = GlobalService();

  Color snackBarBackgroud = const Color.fromRGBO(248, 248, 248, 1);

  Future<void> login(BuildContext context, LoginRequest request) async {
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
        AppMessages.showSnackbar(context, OlukoLocalizations.of(context).find('passwordSpaceWarning'),
            backgroundColor: snackBarBackgroud, textColor: Colors.black);
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
    if (user.currentPlan == -100) {
      FirebaseAuth.instance.signOut();
      AppMessages.clearAndShowSnackbarTranslated(context, 'pleaseSubscribeToAPlanBeforeUsingTheApp');
      emit(AuthGuest());
      return;
    } else if (firebaseUser?.emailVerified != null ? !firebaseUser.emailVerified : true) {
      //TODO: trigger to send another email
      await firebaseUser?.updateEmail(user.email);
      firebaseUser?.sendEmailVerification();
      FirebaseAuth.instance.signOut();
      AppMessages.clearAndShowSnackbarTranslated(context, 'pleaseCheckYourEmail');
      emit(AuthGuest());
    } else {
      AuthRepository().storeLoginData(user);
      if (firebaseUser != null) {
        AppMessages.clearAndShowSnackbar(context, '${OlukoLocalizations.get(context, 'welcome')}, ${user.firstName}');
        emit(AuthSuccess(user: user, firebaseUser: firebaseUser));
        navigateToNextScreen(context, firebaseUser.uid);
        final sharedPref = await SharedPreferences.getInstance();
        if (sharedPref.getBool('first_time') == true) {
          sharedPref.setBool('first_time', false);
          await Permissions.askForPermissions();
        }
      }
    }
  }

  void navigateToNextScreen(BuildContext context, String userId) async {
    AssessmentAssignment assessmentA = await AssessmentAssignmentRepository.getByUserId(userId);
    if (assessmentA != null && (assessmentA.seenByUser == null || !assessmentA.seenByUser)) {
      await AppNavigator().goToAssessmentVideos(context);
    } else {
      await AppNavigator().returnToHome(context);
    }
  }

  Future<void> loginWithGoogle(BuildContext context) async {
    emit(AuthLoading());
    UserCredential result;
    try {
      try {
        result = await _authRepository.signInWithGoogle();
      } on FirebaseAuthException catch (error) {
        AppMessages.clearAndShowSnackbar(
            context, OlukoLocalizations.get(context, 'accountAlreadyExistsWithThisEmailUsingADifferentProvider'));
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
      User firebaseUser = result.user;
      UserResponse userResponse = await UserRepository().get(firebaseUser?.email);

      //If there is no associated user for this account
      if (userResponse == null) {
        FirebaseAuth.instance.signOut();
        AppMessages.clearAndShowSnackbar(context, OlukoLocalizations.get(context, 'userForThisAccountNotFoundPleaseSignUp'));
        emit(AuthGuest());
        return;
      }

      AuthRepository().storeLoginData(userResponse);
      if (firebaseUser != null) {
        emit(AuthSuccess(user: userResponse, firebaseUser: firebaseUser));
        AppMessages.clearAndShowSnackbar(
            context, '${OlukoLocalizations.get(context, 'welcome')}, ${userResponse?.firstName ?? userResponse?.username}');
        navigateToNextScreen(context, firebaseUser.uid);
        final sharedPref = await SharedPreferences.getInstance();
        if (sharedPref.getBool('first_time') == true) {
          sharedPref.setBool('first_time', false);
          await Permissions.askForPermissions();
        }
      }
      // ignore: avoid_catching_errors
    } on NoSuchMethodError catch (e) {
      if (OlukoNeumorphism.isNeumorphismDesign) {
        Navigator.pushNamed(context, routeLabels[RouteEnum.signUpNeumorphic]);
      } else {
        Navigator.pushNamed(context, routeLabels[RouteEnum.signUp]);
      }
    }
  }

  Future<void> loginWithFacebook(BuildContext context) async {
    UserCredential result;
    try {
      result = await _authRepository.signInWithFacebook();
    } on FirebaseAuthException catch (error) {
      AppMessages.clearAndShowSnackbar(
          context, OlukoLocalizations.get(context, 'accountAlreadyExistsWithThisEmailUsingADifferentProvider'));
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
      User firebaseUser = result.user;
      UserResponse user = await UserRepository().get(firebaseUser.email);

      //If there is no associated user for this account
      if (user == null) {
        FirebaseAuth.instance.signOut();
        AppMessages.clearAndShowSnackbar(context, OlukoLocalizations.get(context, 'userForThisAccountNotFoundPleaseSignUp'));
        emit(AuthGuest());
        return;
      }

      AuthRepository().storeLoginData(user);
      emit(AuthSuccess(user: user, firebaseUser: firebaseUser));
      navigateToNextScreen(context, firebaseUser.uid);
    }
  }

  Future<UserResponse> retrieveLoginData() {
    return AuthRepository().retrieveLoginData();
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

  Future<void> logout(BuildContext context) async {
    _globalService.videoProcessing = false;

    final success = await AuthRepository().removeLoginData();
    if (success == true) {
      BlocProvider.of<CoachMentoredVideosBloc>(context).dispose();
      BlocProvider.of<CoachRecommendationsBloc>(context).dispose();
      BlocProvider.of<CoachTimelineItemsBloc>(context).dispose();
      BlocProvider.of<StoryListBloc>(context).dispose();
      BlocProvider.of<CoachSentVideosBloc>(context).dispose();
      BlocProvider.of<CoachReviewPendingBloc>(context).dispose();
      BlocProvider.of<CourseEnrollmentListStreamBloc>(context).dispose();
      BlocProvider.of<ChallengeStreamBloc>(context).dispose();
      BlocProvider.of<CourseSubscriptionBloc>(context).dispose();
      BlocProvider.of<CourseCategoryBloc>(context).dispose();
      BlocProvider.of<CoachRequestStreamBloc>(context).dispose();
      BlocProvider.of<NotificationBloc>(context).dispose();
      BlocProvider.of<CoachMediaBloc>(context).dispose();
      if (OlukoNeumorphism.isNeumorphismDesign) {
        Navigator.pushNamedAndRemoveUntil(context, routeLabels[RouteEnum.signUpNeumorphic], (route) => false);
      } else {
        Navigator.pushNamedAndRemoveUntil(context, routeLabels[RouteEnum.signUp], (route) => false);
      }
      emit(AuthGuest());
    }
  }

  Future<void> sendPasswordResetEmail(BuildContext context, LoginRequest loginRequest) async {
    if (loginRequest.email == null || loginRequest.email == '') {
      AppMessages.clearAndShowSnackbar(context, OlukoLocalizations.get(context, 'enterEmail'));
      return;
    }

    try {
      await AuthRepository().sendPasswordResetEmail(loginRequest.email);
      AppMessages.clearAndShowSnackbar(context, OlukoLocalizations.get(context, 'pleaseCheckYourEmailForInstructions'));
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
    List<String> splitDisplayName = firebaseUser.displayName.split(' ');
    SignUpRequest signUpRequest = SignUpRequest(
      email: firebaseUser.email,
      firstName: splitDisplayName[0],
      lastName: splitDisplayName[1],
      projectId: GlobalConfiguration().getValue('projectId'),
    );
    UserResponse response = await UserRepository().createSSO(signUpRequest);
    return response;
  }
}
