import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/assessment_assignment_bloc.dart';
import 'package:oluko_app/blocs/assessment_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/course_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment_bloc.dart';
import 'package:oluko_app/blocs/friend_bloc.dart';
import 'package:oluko_app/blocs/tag_bloc.dart';
import 'package:oluko_app/blocs/task_submission_bloc.dart';
import 'package:oluko_app/config/s3_settings.dart';
import 'package:oluko_app/models/assessment_assignment.dart';
import 'package:oluko_app/repositories/auth_repository.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';
import 'package:oluko_app/ui/screens/app_plans.dart';
import 'package:oluko_app/ui/screens/assessment_videos.dart';
import 'package:oluko_app/ui/screens/choose_plan_payment.dart';
import 'package:oluko_app/ui/screens/classes.dart';
import 'package:oluko_app/ui/screens/courses.dart';
import 'package:oluko_app/ui/screens/friends_page.dart';
import 'package:oluko_app/ui/screens/home_page.dart';
import 'package:oluko_app/ui/screens/Login.dart';
import 'package:oluko_app/ui/screens/Profile.dart';
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
      routes: {
        '/': (context) => MultiBlocProvider(providers: [
              BlocProvider.value(value: _authBloc),
              BlocProvider(create: (context) => CourseBloc()),
              BlocProvider(create: (context) => TagBloc())
            ], child: MyHomePage()),
        '/sign-up': (context) =>
            BlocProvider.value(value: _authBloc, child: SignUpPage()),
        '/sign-up-with-email': (context) =>
            BlocProvider.value(value: _authBloc, child: SignUpWithMailPage()),

        '/friends': (context) => MultiBlocProvider(providers: [
              BlocProvider.value(
                value: _authBloc,
              ),
              BlocProvider(create: (context) => FriendBloc()),
            ], child: FriendsPage()),

        '/profile': (context) =>
            BlocProvider.value(value: _authBloc, child: ProfilePage()),
        '/profile-settings': (context) =>
            BlocProvider.value(value: _authBloc, child: ProfileSettingsPage()),
        '/profile-my-account': (context) =>
            BlocProvider.value(value: _authBloc, child: ProfileMyAccountPage()),
        '/profile-subscription': (context) => BlocProvider.value(
            value: _authBloc, child: ProfileSubscriptionPage()),
        '/profile-help-and-support': (context) => BlocProvider.value(
            value: _authBloc, child: ProfileHelpAndSupportPage()),

        '/profile-view-own-profile': (context) => MultiBlocProvider(providers: [
              BlocProvider.value(value: _authBloc),
              BlocProvider(create: (context) => CourseBloc()),
              BlocProvider(create: (context) => AssessmentBloc()),
              BlocProvider(create: (context) => TaskSubmissionBloc()),
              BlocProvider(create: (context) => CourseEnrollmentBloc()),
              BlocProvider(create: (context) => TransformationJourneyBloc())
            ], child: ProfileOwnProfilePage()),

        '/profile-challenges': (context) => BlocProvider.value(
            value: _authBloc, child: ProfileChallengesPage()),
        '/profile-transformation-journey': (context) => BlocProvider.value(
            value: _authBloc, child: ProfileTransformationJourneyPage()),
        '/transformation-journey-post': (context) => BlocProvider.value(
            value: _authBloc, child: TransformationJourneyPostPage()),
        '/transformation-journey-post-view': (context) => BlocProvider.value(
            value: _authBloc, child: TransformationJourneyPostPage()),
        '/log-in': (context) =>
            BlocProvider.value(value: _authBloc, child: LoginPage()),
        '/app-plans': (context) =>
            BlocProvider.value(value: _authBloc, child: AppPlans()),
        //TODO: Remove this when take it to the correct place inside courses
        '/segment-detail': (context) =>
            BlocProvider.value(value: _authBloc, child: SegmentDetail()),
        '/movement-intro': (context) =>
            BlocProvider.value(value: _authBloc, child: MovementIntro()),
        '/segment-recording': (context) =>
            BlocProvider.value(value: _authBloc, child: SegmentRecording()),
        '/classes': (context) =>
            BlocProvider.value(value: _authBloc, child: Classes()),
        '/assessment-videos': (context) =>
            BlocProvider.value(value: _authBloc, child: AssessmentVideos()),
        '/task-details': (context) => BlocProvider.value(
            value: _authBloc,
            child: TaskDetails(
              task: Task(description: 'Task Description'),
            )),
        '/choose-plan-payment': (context) =>
            BlocProvider.value(value: _authBloc, child: ChoosePlayPayments()),
        '/courses': (context) => MultiBlocProvider(providers: [
              BlocProvider.value(value: _authBloc),
              BlocProvider(create: (context) => CourseBloc()),
              BlocProvider(create: (context) => TagBloc())
            ], child: Courses()),
        '/videos': (context) => BlocProvider.value(
            value: _authBloc,
            child: Home(
              title: "Videos",
              parentVideoInfo: null,
              parentVideoReference:
                  FirebaseFirestore.instance.collection("videosInfo"),
            ))
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
