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

  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '${OLUKO}',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      initialRoute: widget.initialRoute,
      onGenerateRoute: (RouteSettings settings) {
        Widget newRoute;
        switch (settings.name) {
          case '/':
            newRoute = MultiBlocProvider(providers: [
              BlocProvider(create: (context) => CourseBloc()),
              BlocProvider(create: (context) => TagBloc())
            ], child: MainPage());
            break;
          case '/sign-up':
            newRoute = SignUpPage();
            break;
          case '/sign-up-with-email':
            newRoute = SignUpWithMailPage();
            break;
          case '/friends':
            newRoute = MultiBlocProvider(providers: [
              BlocProvider(create: (context) => FriendBloc()),
            ], child: FriendsPage());
            break;
          case '/profile':
            newRoute = ProfilePage();
            break;
          case '/profile-settings':
            newRoute = ProfileSettingsPage();
            break;
          case '/profile-my-account':
            newRoute = ProfileMyAccountPage();
            break;
          case '/profile-subscription':
            newRoute = ProfileSubscriptionPage();
            break;
          case '/profile-help-and-support':
            newRoute = ProfileHelpAndSupportPage();
            break;
          case '/profile-view-own-profile':
            newRoute = MultiBlocProvider(providers: [
              BlocProvider(create: (context) => CourseBloc()),
              BlocProvider(create: (context) => AssessmentBloc()),
              BlocProvider(create: (context) => TaskSubmissionBloc()),
              BlocProvider(create: (context) => CourseEnrollmentBloc()),
              BlocProvider(create: (context) => TransformationJourneyBloc())
            ], child: ProfileOwnProfilePage());
            break;
          case '/profile-challenges':
            newRoute = ProfileChallengesPage();
            break;
          case '/profile-transformation-journey':
            newRoute = MultiBlocProvider(providers: [
              BlocProvider(create: (context) => CourseBloc()),
              BlocProvider(create: (context) => AssessmentBloc()),
              BlocProvider(create: (context) => TaskSubmissionBloc()),
              BlocProvider(create: (context) => CourseEnrollmentBloc()),
              BlocProvider(create: (context) => TransformationJourneyBloc())
            ], child: ProfileTransformationJourneyPage());
            break;
          case '/transformation-journey-post':
            newRoute = TransformationJourneyPostPage();
            break;
          case '/transformation-journey-post-view':
            newRoute = TransformationJourneyPostPage();
            break;
          case '/log-in':
            newRoute = LoginPage();
            break;
          case '/app-plans':
            newRoute = AppPlans();
            break;
          case '/segment-detail':
            newRoute = SegmentDetail();
            break;
          case '/movement-intro':
            newRoute = MovementIntro();
            break;
          case '/segment-recording':
            newRoute = SegmentRecording();
            break;
          case '/classes':
            newRoute = Classes();
            break;
          case '/assessment-videos':
            newRoute = AssessmentVideos();
            break;
          case '/task-details':
            newRoute = TaskDetails(
              task: Task(description: 'Task Description'),
            );
            break;
          case '/choose-plan-payment':
            newRoute = ChoosePlayPayments();
            break;
          case '/courses':
            newRoute = MultiBlocProvider(providers: [
              BlocProvider(create: (context) => CourseBloc()),
              BlocProvider(create: (context) => TagBloc())
            ], child: Courses());
            break;
          case '/videos':
            newRoute = Home(
              title: "Videos",
              parentVideoInfo: null,
              parentVideoReference:
                  FirebaseFirestore.instance.collection("videosInfo"),
            );
            break;
          default:
            break;
        }

        return MaterialPageRoute(
            builder: (context) => MultiBlocProvider(
                providers: [BlocProvider.value(value: _authBloc)],
                child: newRoute));
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
