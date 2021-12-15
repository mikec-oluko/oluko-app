import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/blocs/coach/coach_user_bloc.dart';
import 'package:oluko_app/blocs/course_category_bloc.dart';
import 'package:oluko_app/blocs/story_list_bloc.dart';
import 'package:oluko_app/models/assessment_assignment.dart';
import 'package:oluko_app/models/dto/api_response.dart';
import 'package:oluko_app/models/dto/login_request.dart';
import 'package:oluko_app/models/sign_up_request.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/repositories/assessment_assignment_repository.dart';
import 'package:oluko_app/repositories/auth_repository.dart';
import 'package:oluko_app/repositories/user_repository.dart';
import 'package:oluko_app/utils/app_loader.dart';
import 'package:oluko_app/utils/app_messages.dart';
import 'package:oluko_app/utils/app_navigator.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'dart:developer';
import 'coach/coach_interaction_timeline_bloc.dart';
import 'coach/coach_mentored_videos_bloc.dart';
import 'coach/coach_recommendations_bloc.dart';
import 'coach/coach_request_bloc.dart';
import 'coach/coach_review_pending_bloc.dart';
import 'coach/coach_sent_videos_bloc.dart';
import 'course/course_bloc.dart';
import 'course_enrollment/course_enrollment_list_bloc.dart';

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

  Future<void> login(BuildContext context, LoginRequest request) async {
    if (request.email == null && request.userName.isEmpty && request.password.isEmpty) {
      AppMessages.showSnackbarTranslated(context, 'invalidUsernameOrPw');
      return;
    }

    if (request.email == null && request.userName.isEmpty) {
      AppMessages.showSnackbarTranslated(context, 'emailUsernameRequired');
      return;
    }

    if (request.password.isEmpty) {
      AppMessages.showSnackbarTranslated(context, 'passwordRequired');
      return;
    }
    AppLoader.startLoading(context);
    final ApiResponse apiResponse = await _authRepository.login(request);
    AppLoader.stopLoading();
    if (apiResponse.statusCode != 200) {
      //TODO: response should bring key apiResponse.message
      AppMessages.showSnackbarTranslated(context, 'invalidUsernameOrPw');
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
      AppMessages.showSnackbarTranslated(context, 'pleaseSubscribeToAPlanBeforeUsingTheApp');
      emit(AuthGuest());
      return;
    } else if (!firebaseUser.emailVerified) {
      //TODO: trigger to send another email
      await firebaseUser.updateEmail(user.email);
      firebaseUser.sendEmailVerification();
      FirebaseAuth.instance.signOut();
      AppMessages.showSnackbarTranslated(context, 'pleaseCheckYourEmail');
      emit(AuthGuest());
    } else {
      AuthRepository().storeLoginData(user);
      AppMessages.showSnackbar(context, '${OlukoLocalizations.get(context, 'welcome')}, ${user.firstName}');
      emit(AuthSuccess(user: user, firebaseUser: firebaseUser));
      navigateToNextScreen(context, firebaseUser.uid);
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
    UserCredential result;
    try {
      try {
        result = await _authRepository.signInWithGoogle();
      } on FirebaseAuthException catch (error) {
        AppMessages.showSnackbar(context, OlukoLocalizations.get(context, 'accountAlreadyExistsWithThisEmailUsingADifferentProvider'));
        rethrow;
      } catch (error) {
        AppMessages.showSnackbar(context, OlukoLocalizations.get(context, 'errorOccurred'));
        rethrow;
      }
      if (result == null) {
        FirebaseAuth.instance.signOut();
        AppMessages.showSnackbar(context, OlukoLocalizations.get(context, 'errorOccurred'));
        emit(AuthGuest());
        return;
      }
      User firebaseUser = result.user;
      UserResponse userResponse = await UserRepository().get(firebaseUser.email);

      //If there is no associated user for this account
      if (userResponse == null) {
        FirebaseAuth.instance.signOut();
        AppMessages.showSnackbar(context, OlukoLocalizations.get(context, 'userForThisAccountNotFoundPleaseSignUp'));
        emit(AuthGuest());
        return;
      }

      AuthRepository().storeLoginData(userResponse);
      emit(AuthSuccess(user: userResponse, firebaseUser: firebaseUser));
      navigateToNextScreen(context, firebaseUser.uid);
      // ignore: avoid_catching_errors
    } on NoSuchMethodError catch (e) {
      Navigator.pushNamed(context, '/log-in');
    }
  }

  Future<void> loginWithFacebook(BuildContext context) async {
    UserCredential result;
    try {
      result = await _authRepository.signInWithFacebook();
    } on FirebaseAuthException catch (error) {
      AppMessages.showSnackbar(context, OlukoLocalizations.get(context, 'accountAlreadyExistsWithThisEmailUsingADifferentProvider'));
      rethrow;
    } catch (error) {
      AppMessages.showSnackbar(context, OlukoLocalizations.get(context, 'errorOccurred'));
      rethrow;
    }
    if (result == null) {
      FirebaseAuth.instance.signOut();
      AppMessages.showSnackbar(context, OlukoLocalizations.get(context, 'errorOccurred'));
      emit(AuthGuest());
      return;
    }

    if (result != null) {
      User firebaseUser = result.user;
      UserResponse user = await UserRepository().get(firebaseUser.email);

      //If there is no associated user for this account
      if (user == null) {
        FirebaseAuth.instance.signOut();
        AppMessages.showSnackbar(context, OlukoLocalizations.get(context, 'userForThisAccountNotFoundPleaseSignUp'));
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

  Future<User> checkCurrentUser() async {
    final loggedUser = AuthRepository.getLoggedUser();
    final userData = await AuthRepository().retrieveLoginData();
    if (loggedUser != null && userData != null) {
      emit(AuthSuccess(user: userData, firebaseUser: loggedUser));
      return loggedUser;
    } else {
      emit(AuthGuest());
      return null;
    }
  }

  Future<void> logout(BuildContext context) async {
    final success = await AuthRepository().removeLoginData();
    if (success == true) {
      BlocProvider.of<CoachMentoredVideosBloc>(context).dispose();
      BlocProvider.of<CoachRecommendationsBloc>(context).dispose();
      BlocProvider.of<CoachRequestBloc>(context).dispose();
      BlocProvider.of<CoachTimelineItemsBloc>(context).dispose();
      BlocProvider.of<StoryListBloc>(context).dispose();
      BlocProvider.of<CoachSentVideosBloc>(context).dispose();
      BlocProvider.of<CoachReviewPendingBloc>(context).dispose();
      BlocProvider.of<CourseEnrollmentListBloc>(context).dispose();
      BlocProvider.of<CourseBloc>(context).dispose();
      BlocProvider.of<CourseCategoryBloc>(context).dispose();
      Navigator.pushNamedAndRemoveUntil(context, '/sign-up', (route) => false);
      emit(AuthGuest());
    }
  }

  Future<void> sendPasswordResetEmail(BuildContext context, LoginRequest loginRequest) async {
    if (loginRequest.email == null || loginRequest.email == '') {
      AppMessages.showSnackbar(context, OlukoLocalizations.get(context, 'enterEmail'));
      return;
    }

    await AuthRepository().sendPasswordResetEmail(loginRequest.email);
    AppMessages.showSnackbar(context, OlukoLocalizations.get(context, 'pleaseCheckYourEmailForInstructions'));
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
