import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/assessment_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/course_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment_bloc.dart';
import 'package:oluko_app/blocs/favorite_bloc.dart';
import 'package:oluko_app/blocs/friend_bloc.dart';
import 'package:oluko_app/blocs/profile_bloc.dart';
import 'package:oluko_app/blocs/tag_bloc.dart';
import 'package:oluko_app/blocs/task_submission_bloc.dart';
import 'package:oluko_app/blocs/transformation_journey_bloc.dart';
import 'package:oluko_app/ui/screens/app_plans.dart';
import 'package:oluko_app/ui/screens/assessment_videos.dart';
import 'package:oluko_app/ui/screens/choose_plan_payment.dart';
import 'package:oluko_app/ui/screens/classes.dart';
import 'package:oluko_app/ui/screens/courses.dart';
import 'package:oluko_app/ui/screens/friends_page.dart';
import 'package:oluko_app/ui/screens/login.dart';
import 'package:oluko_app/ui/screens/main_page.dart';
import 'package:oluko_app/ui/screens/movement_intro.dart';
import 'package:oluko_app/ui/screens/profile.dart';
import 'package:oluko_app/ui/screens/profile/profile_challenges_page.dart';
import 'package:oluko_app/ui/screens/profile/profile_help_and_support_page.dart';
import 'package:oluko_app/ui/screens/profile/profile_my_account_page.dart';
import 'package:oluko_app/ui/screens/profile/user_profile_page.dart';
import 'package:oluko_app/ui/screens/profile/profile_settings_page.dart';
import 'package:oluko_app/ui/screens/profile/profile_subscription_page.dart';
import 'package:oluko_app/ui/screens/profile/profile_transformation_journey_page.dart';
import 'package:oluko_app/ui/screens/profile/transformation_journey_post.dart';
import 'package:oluko_app/ui/screens/segment_detail.dart';
import 'package:oluko_app/ui/screens/segment_recording.dart';
import 'package:oluko_app/ui/screens/sign_up.dart';
import 'package:oluko_app/ui/screens/sign_up_with_email.dart';
import 'package:oluko_app/ui/screens/task_details.dart';
import 'package:oluko_app/ui/screens/videos/home.dart';
import 'models/task.dart';

enum RouteEnum {
  root,
  signUp,
  signUpWithEmail,
  friends,
  profile,
  profileSettings,
  profileMyAccount,
  profileSubscription,
  profileHelpAndSupport,
  profileViewOwnProfile,
  profileChallenges,
  profileTransformationJourney,
  transformationJourneyPost,
  transformationJourneyPostView,
  logIn,
  appPlans,
  segmentDetails,
  movementIntro,
  segmentRecording,
  classes,
  assessmentVideos,
  taskDetails,
  choosePlanPayment,
  courses,
  videos
}

Map<RouteEnum, String> routeLabels = {
  RouteEnum.root: '/',
  RouteEnum.signUp: '/sign-up',
  RouteEnum.signUpWithEmail: '/sign-up-with-email',
  RouteEnum.friends: '/friends',
  RouteEnum.profile: '/profile',
  RouteEnum.profileSettings: '/profile-settings',
  RouteEnum.profileMyAccount: '/profile-my-account',
  RouteEnum.profileSubscription: '/profile-subscription',
  RouteEnum.profileHelpAndSupport: '/profile-help-and-support',
  RouteEnum.profileViewOwnProfile: '/profile-view-user-profile',
  RouteEnum.profileChallenges: '/profile-challenges',
  RouteEnum.profileTransformationJourney: '/profile-transformation-journey',
  RouteEnum.transformationJourneyPost: '/transformation-journey-post',
  RouteEnum.transformationJourneyPostView: '/transformation-journey-post-view',
  RouteEnum.logIn: '/log-in',
  RouteEnum.appPlans: '/app-plans',
  RouteEnum.segmentDetails: '/segment-detail',
  RouteEnum.movementIntro: '/movement-intro',
  RouteEnum.segmentRecording: '/segment-recording',
  RouteEnum.classes: '/classes',
  RouteEnum.assessmentVideos: '/assessment-videos',
  RouteEnum.taskDetails: '/task-details',
  RouteEnum.choosePlanPayment: '/choose-plan-payment',
  RouteEnum.courses: '/courses',
  RouteEnum.videos: '/videos',
};

RouteEnum getEnumFromRouteString(String route) {
  final routeIndex = routeLabels.values.toList().indexOf(route);
  return routeIndex != -1 ? routeLabels.keys.toList()[routeIndex] : null;
}

class Routes {
  final AuthBloc _authBloc = AuthBloc();
  final ProfileBloc _profileBloc = ProfileBloc();
  final CourseBloc _courseBloc = CourseBloc();
  final TagBloc _tagBloc = TagBloc();
  final FriendBloc _friendBloc = FriendBloc();
  final AssessmentBloc _assessmentBloc = AssessmentBloc();
  final TaskSubmissionBloc _taskSubmissionBloc = TaskSubmissionBloc();
  final CourseEnrollmentBloc _courseEnrollmentBloc = CourseEnrollmentBloc();
  final TransformationJourneyBloc _transformationJourneyBloc =
      TransformationJourneyBloc();
  final FavoriteBloc _favoriteBloc = FavoriteBloc();

  getRouteView(String route, Object arguments) {
    //View for the new route.
    Widget newRouteView;
    //Providers used for the new route.
    List<BlocProvider> providers = [];
    //Providers used across the whole app.
    List<BlocProvider> commonProviders = [
      BlocProvider<AuthBloc>.value(value: _authBloc)
    ];

    final RouteEnum routeEnum = getEnumFromRouteString(route);
    switch (routeEnum) {
      case RouteEnum.root:
        providers = [
          BlocProvider<CourseBloc>.value(value: _courseBloc),
          BlocProvider<TagBloc>.value(value: _tagBloc),
          BlocProvider<CourseEnrollmentBloc>.value(value: _courseEnrollmentBloc),
          BlocProvider<FavoriteBloc>.value(value: _favoriteBloc),
        ];
        newRouteView = MainPage();
        break;
      case RouteEnum.signUp:
        newRouteView = SignUpPage();
        break;
      case RouteEnum.signUpWithEmail:
        newRouteView = SignUpWithMailPage();
        break;
      case RouteEnum.friends:
        providers = [BlocProvider<FriendBloc>.value(value: _friendBloc)];
        newRouteView = FriendsPage();
        break;
      case RouteEnum.profile:
        newRouteView = ProfilePage();
        break;
      case RouteEnum.profileSettings:
        newRouteView = ProfileSettingsPage();
        break;
      case RouteEnum.profileMyAccount:
        providers = [
          BlocProvider<ProfileBloc>.value(value: _profileBloc),
          BlocProvider<TransformationJourneyBloc>.value(
              value: _transformationJourneyBloc)
        ];
        newRouteView = ProfileMyAccountPage();
        break;
      case RouteEnum.profileSubscription:
        newRouteView = ProfileSubscriptionPage();
        break;
      case RouteEnum.profileHelpAndSupport:
        newRouteView = ProfileHelpAndSupportPage();
        break;
      case RouteEnum.profileViewOwnProfile:
        providers = [
          BlocProvider<CourseBloc>.value(value: _courseBloc),
          BlocProvider<ProfileBloc>.value(value: _profileBloc),
          BlocProvider<AssessmentBloc>.value(value: _assessmentBloc),
          BlocProvider<TaskSubmissionBloc>.value(value: _taskSubmissionBloc),
          BlocProvider<CourseEnrollmentBloc>.value(
              value: _courseEnrollmentBloc),
          BlocProvider<TransformationJourneyBloc>.value(
              value: _transformationJourneyBloc),
        ];
        newRouteView = UserProfilePage();
        break;
      case RouteEnum.profileChallenges:
        newRouteView = ProfileChallengesPage();
        break;
      case RouteEnum.profileTransformationJourney:
        providers = [
          BlocProvider<ProfileBloc>.value(value: _profileBloc),
          BlocProvider<CourseBloc>.value(value: _courseBloc),
          BlocProvider<AssessmentBloc>.value(value: _assessmentBloc),
          BlocProvider<TaskSubmissionBloc>.value(value: _taskSubmissionBloc),
          BlocProvider<CourseEnrollmentBloc>.value(
              value: _courseEnrollmentBloc),
          BlocProvider<TransformationJourneyBloc>.value(
              value: _transformationJourneyBloc),
        ];
        newRouteView = ProfileTransformationJourneyPage();
        break;
      case RouteEnum.transformationJourneyPost:
        providers = [
          BlocProvider<TransformationJourneyBloc>.value(
              value: _transformationJourneyBloc),
        ];
        newRouteView = TransformationJourneyPostPage();
        break;
      case RouteEnum.transformationJourneyPostView:
        providers = [
          BlocProvider<TransformationJourneyBloc>.value(
              value: _transformationJourneyBloc),
        ];
        newRouteView = TransformationJourneyPostPage();
        break;
      case RouteEnum.logIn:
        newRouteView = LoginPage();
        break;
      case RouteEnum.appPlans:
        newRouteView = AppPlans();
        break;
      case RouteEnum.segmentDetails:
        newRouteView = SegmentDetail();
        break;
      case RouteEnum.movementIntro:
        newRouteView = MovementIntro();
        break;
      case RouteEnum.segmentRecording:
        newRouteView = SegmentRecording();
        break;
      case RouteEnum.classes:
        Map<String, String> parsedArguments = arguments;
        newRouteView = Classes(
          courseId: parsedArguments['courseId'],
        );
        break;
      case RouteEnum.assessmentVideos:
        newRouteView = AssessmentVideos();
        break;
      case RouteEnum.taskDetails:
        newRouteView = TaskDetails(
          task: Task(description: 'Task Description'),
        );
        break;
      case RouteEnum.choosePlanPayment:
        newRouteView = ChoosePlayPayments();
        break;
      case RouteEnum.courses:
        providers = [
          BlocProvider<FavoriteBloc>.value(value: _favoriteBloc),
          BlocProvider<CourseBloc>.value(value: _courseBloc),
          BlocProvider<TagBloc>.value(value: _tagBloc),
        ];
        newRouteView = Courses();
        break;
      case RouteEnum.videos:
        newRouteView = Home(
          title: "Videos",
          parentVideoInfo: null,
          parentVideoReference:
              FirebaseFirestore.instance.collection("videosInfo"),
        );
        break;
      default:
        providers = [
          BlocProvider<CourseBloc>.value(value: _courseBloc),
          BlocProvider<TagBloc>.value(value: _tagBloc),
        ];
        newRouteView = MainPage();
        break;
    }

    //Merge common providers & route-specific ones into one List
    List<BlocProvider> selectedProviders = providers..addAll(commonProviders);

    //Generate route with selected BLoCs
    return MaterialPageRoute(
        builder: (c) => MultiBlocProvider(
            providers: selectedProviders,
            child: Builder(builder: (context) {
              return newRouteView;
            })));
  }
}