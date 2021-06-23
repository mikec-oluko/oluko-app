import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/config/s3_settings.dart';
import 'package:oluko_app/ui/screens/app_plans.dart';
import 'package:oluko_app/ui/screens/assesment_videos.dart';
import 'package:oluko_app/ui/screens/choose_plan_payment.dart';
import 'package:oluko_app/ui/screens/home_page.dart';
import 'package:oluko_app/ui/screens/Login.dart';
import 'package:oluko_app/ui/screens/Profile.dart';
import 'package:oluko_app/ui/screens/profile/profile_my_account_page.dart';
import 'package:oluko_app/ui/screens/profile/profile_settings_screen.dart';
import 'package:oluko_app/ui/screens/profile/profile_subscription.dart';
import 'package:oluko_app/ui/screens/self_recording_preview.dart';
import 'package:oluko_app/ui/screens/sign_up_with_email.dart';
import 'package:oluko_app/ui/screens/sign_up.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:oluko_app/ui/screens/task_details.dart';
import 'package:oluko_app/ui/screens/videos/home.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/utils/OlukoLocalizations.dart';
import 'config/project_settings.dart';
import 'models/task.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GlobalConfiguration().loadFromMap(projectSettings);
  GlobalConfiguration().loadFromMap(s3Settings);
  await Firebase.initializeApp();
  runApp(MyApp());
}

const OLUKO = 'Oluko';

class MyApp extends StatefulWidget {
  // This widget is the root of your application.

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AuthBloc _authBloc = AuthBloc();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '${OLUKO}',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) =>
            BlocProvider.value(value: _authBloc, child: MyHomePage(title: '')),
        '/sign-up': (context) =>
            BlocProvider.value(value: _authBloc, child: SignUpPage()),
        '/sign-up-with-email': (context) =>
            BlocProvider.value(value: _authBloc, child: SignUpWithMailPage()),
        '/profile': (context) =>
            BlocProvider.value(value: _authBloc, child: ProfilePage()),
        '/profile-settings': (context) =>
            BlocProvider.value(value: _authBloc, child: ProfileSettingsPage()),
        '/profile-my-account': (context) =>
            BlocProvider.value(value: _authBloc, child: ProfileMyAccountPage()),
        '/profile-subscription': (context) => BlocProvider.value(
            value: _authBloc, child: ProfileSubscriptionPage()),
        '/log-in': (context) =>
            BlocProvider.value(value: _authBloc, child: LoginPage()),
        '/app-plans': (context) =>
            BlocProvider.value(value: _authBloc, child: AppPlans()),
        '/assessment-videos': (context) =>
            BlocProvider.value(value: _authBloc, child: AsessmentVideos()),
        '/task-details': (context) => BlocProvider.value(
            value: _authBloc,
            child: TaskDetails(
              task: Task(description: 'Task Description'),
            )),
        '/self-recording-preview': (context) => BlocProvider.value(
            value: _authBloc,
            child: SelfRecordingPreview(
              task: Task(description: 'Task Description', name: 'Task 1'),
            )),
        '/choose-plan-payment': (context) =>
            BlocProvider.value(value: _authBloc, child: ChoosePlayPayments()),
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
