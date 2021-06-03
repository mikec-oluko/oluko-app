import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/ui/screens/home_page.dart';
import 'package:oluko_app/ui/screens/Login.dart';
import 'package:oluko_app/ui/screens/Profile.dart';
import 'package:oluko_app/ui/screens/sign_up_with_email.dart';
import 'package:oluko_app/ui/screens/sign_up.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:oluko_app/ui/screens/videos/home.dart';
import 'package:global_configuration/global_configuration.dart';
import 'config/project_settings.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  GlobalConfiguration().loadFromMap(projectSettings);
  runApp(MyApp());
}

const OLUKO = 'Oluko';

class MyApp extends StatefulWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
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
        '/log-in': (context) =>
            BlocProvider.value(value: _authBloc, child: LoginPage()),
        '/videos': (context) => BlocProvider.value(
            value: _authBloc,
            child: Home(
              title: "Videos",
              videoParent: null,
              videoParentPath: "",
            ))
      },
      localizationsDelegates: [
        AppLocalizations.delegate,
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
