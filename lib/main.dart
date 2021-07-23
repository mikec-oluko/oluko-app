import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/assessment_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/course_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment_bloc.dart';
import 'package:oluko_app/blocs/friend_bloc.dart';
import 'package:oluko_app/blocs/tag_bloc.dart';
import 'package:oluko_app/blocs/task_submission_bloc.dart';
import 'package:oluko_app/config/s3_settings.dart';
import 'package:oluko_app/ui/screens/app_plans.dart';
import 'package:oluko_app/ui/screens/assessment_videos.dart';
import 'package:oluko_app/ui/screens/choose_plan_payment.dart';
import 'package:oluko_app/ui/screens/classes.dart';
import 'package:oluko_app/ui/screens/courses.dart';
import 'package:oluko_app/ui/screens/friends_page.dart';
import 'package:oluko_app/ui/screens/Login.dart';
import 'package:oluko_app/ui/screens/Profile.dart';
import 'package:oluko_app/ui/screens/main_page.dart';
import 'package:oluko_app/ui/screens/movement_intro.dart';
import 'package:oluko_app/ui/screens/segment_detail.dart';
import 'package:oluko_app/ui/screens/profile/profile_challenges_page.dart';
import 'package:oluko_app/ui/screens/profile/profile_help_and_support_page.dart';
import 'package:oluko_app/ui/screens/profile/profile_my_account_page.dart';
import 'package:oluko_app/ui/screens/profile/profile_own_profile_page.dart';
import 'package:oluko_app/ui/screens/profile/profile_settings_page.dart';
import 'package:oluko_app/ui/screens/profile/profile_subscription_page.dart';
import 'package:oluko_app/ui/screens/profile/profile_transformation_journey_page.dart';
import 'package:oluko_app/ui/screens/profile/transformation_journey_post.dart';
import 'package:oluko_app/ui/screens/segment_recording.dart';
import 'package:oluko_app/ui/screens/sign_up_with_email.dart';
import 'package:oluko_app/ui/screens/sign_up.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:oluko_app/ui/screens/task_details.dart';
import 'package:oluko_app/ui/screens/videos/home.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'blocs/transformation_journey_bloc.dart';
import 'config/project_settings.dart';
import 'models/task.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GlobalConfiguration().loadFromMap(projectSettings);
  GlobalConfiguration().loadFromMap(s3Settings);
  await Firebase.initializeApp();
  User alreadyLoggedUser = await AuthBloc().checkCurrentUser();
  final MyApp myApp = MyApp(
    initialRoute: alreadyLoggedUser == null ? '/sign-up' : '/',
  );
  runApp(myApp);
}

const OLUKO = 'Oluko';

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  final String initialRoute;

  MyApp({this.initialRoute});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AuthBloc _authBloc = AuthBloc();
  final CourseBloc _courseBloc = CourseBloc();
  final TagBloc _tagBloc = TagBloc();
  final FriendBloc _friendBloc = FriendBloc();
  final AssessmentBloc _assessmentBloc = AssessmentBloc();
  final TaskSubmissionBloc _taskSubmissionBloc = TaskSubmissionBloc();
  final CourseEnrollmentBloc _courseEnrollmentBloc = CourseEnrollmentBloc();
  final TransformationJourneyBloc _transformationJourneyBloc =
      TransformationJourneyBloc();

  Widget build(BuildContext mainContext) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '${OLUKO}',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      initialRoute: widget.initialRoute,
      onGenerateRoute: (RouteSettings settings) {
        //View for the new route.
        Widget newRouteView;
        //Providers used for the new route.
        List<BlocProvider> providers = [];
        //Providers used across the whole app.
        List<BlocProvider> commonProviders = [
          BlocProvider<AuthBloc>.value(value: _authBloc)
        ];

        switch (settings.name) {
          case '/':
            providers = [
              BlocProvider<CourseBloc>.value(value: _courseBloc),
              BlocProvider<TagBloc>.value(value: _tagBloc)
            ];
            newRouteView = MainPage();
            break;
          case '/sign-up':
            newRouteView = SignUpPage();
            break;
          case '/sign-up-with-email':
            newRouteView = SignUpWithMailPage();
            break;
          case '/friends':
            providers = [BlocProvider<FriendBloc>.value(value: _friendBloc)];
            newRouteView = FriendsPage();
            break;
          case '/profile':
            newRouteView = ProfilePage();
            break;
          case '/profile-settings':
            newRouteView = ProfileSettingsPage();
            break;
          case '/profile-my-account':
            newRouteView = ProfileMyAccountPage();
            break;
          case '/profile-subscription':
            newRouteView = ProfileSubscriptionPage();
            break;
          case '/profile-help-and-support':
            newRouteView = ProfileHelpAndSupportPage();
            break;
          case '/profile-view-own-profile':
            providers = [
              BlocProvider<CourseBloc>.value(value: _courseBloc),
              BlocProvider<AssessmentBloc>.value(value: _assessmentBloc),
              BlocProvider<TaskSubmissionBloc>.value(
                  value: _taskSubmissionBloc),
              BlocProvider<CourseEnrollmentBloc>.value(
                  value: _courseEnrollmentBloc),
              BlocProvider<TransformationJourneyBloc>.value(
                  value: _transformationJourneyBloc),
            ];
            newRouteView = ProfileOwnProfilePage();
            break;
          case '/profile-challenges':
            newRouteView = ProfileChallengesPage();
            break;
          case '/profile-transformation-journey':
            providers = [
              BlocProvider<CourseBloc>.value(value: _courseBloc),
              BlocProvider<AssessmentBloc>.value(value: _assessmentBloc),
              BlocProvider<TaskSubmissionBloc>.value(
                  value: _taskSubmissionBloc),
              BlocProvider<CourseEnrollmentBloc>.value(
                  value: _courseEnrollmentBloc),
              BlocProvider<TransformationJourneyBloc>.value(
                  value: _transformationJourneyBloc),
            ];
            newRouteView = ProfileTransformationJourneyPage();
            break;
          case '/transformation-journey-post':
            newRouteView = TransformationJourneyPostPage();
            break;
          case '/transformation-journey-post-view':
            newRouteView = TransformationJourneyPostPage();
            break;
          case '/log-in':
            newRouteView = LoginPage();
            break;
          case '/app-plans':
            newRouteView = AppPlans();
            break;
          case '/segment-detail':
            newRouteView = SegmentDetail();
            break;
          case '/movement-intro':
            newRouteView = MovementIntro();
            break;
          case '/segment-recording':
            newRouteView = SegmentRecording();
            break;
          case '/classes':
            newRouteView = Classes();
            break;
          case '/assessment-videos':
            newRouteView = AssessmentVideos();
            break;
          case '/task-details':
            newRouteView = TaskDetails(
              task: Task(description: 'Task Description'),
            );
            break;
          case '/choose-plan-payment':
            newRouteView = ChoosePlayPayments();
            break;
          case '/courses':
            providers = [
              BlocProvider<CourseBloc>.value(value: _courseBloc),
              BlocProvider<TagBloc>.value(value: _tagBloc),
            ];
            newRouteView = Courses();
            break;
          case '/videos':
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
        List<BlocProvider> selectedProviders = providers
          ..addAll(commonProviders);

        //Generate route with selected BLoCs
        return MaterialPageRoute(
            builder: (c) => MultiBlocProvider(
                providers: selectedProviders,
                child: Builder(builder: (context) {
                  return newRouteView;
                })));
      },
      localizationsDelegates: [
        const OlukoLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', ''),
        const Locale('es', ''),
      ],
    );
  }

  @override
  void dispose() {
    _authBloc.close();
    super.dispose();
  }
}
