import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/project_configuration_bloc.dart';
import 'package:oluko_app/config/s3_settings.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/routes.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/user_utils.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:oluko_app/config/project_settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GlobalConfiguration().loadFromMap(projectSettings);
  GlobalConfiguration().loadFromMap(s3Settings);
  await Firebase.initializeApp();
  final User alreadyLoggedUser = await AuthBloc.checkCurrentUserStatic();
  final bool firstTime = await UserUtils.isFirstTime();
  final String route = getInitialRoute(alreadyLoggedUser, firstTime);
  final MyApp myApp = MyApp(
    initialRoute: route,
  );
  if (GlobalConfiguration().getValue('build') == 'local') {
    runApp(myApp);
  } else {
    await SentryFlutter.init(
      (options) {
        options.dsn = GlobalConfiguration().getValue('sentryDsn');
        options.environment = GlobalConfiguration().getValue('environment');
        options.reportSilentFlutterErrors = true;
      },
      appRunner: () => runApp(myApp),
    );
  }
}

String getInitialRoute(User alreadyLoggedUser, bool isFirstTime) {
  if (alreadyLoggedUser == null) {
    if (isFirstTime != null && isFirstTime && OlukoNeumorphism.isNeumorphismDesign) {
      return routeLabels[RouteEnum.introVideo];
    } else {
      if (OlukoNeumorphism.isNeumorphismDesign) {
        return routeLabels[RouteEnum.loginNeumorphic];
      } else {
        return routeLabels[RouteEnum.signUp];
      }
    }
  } else {
    return routeLabels[RouteEnum.root];
  }
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
  Routes routes = Routes();

  @override
  Widget build(BuildContext mainContext) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    ProjectConfigurationBloc().getCourseConfiguration();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '${OLUKO}',
      theme: ThemeData(
        canvasColor: Colors.transparent,
        primarySwatch: Colors.grey,
      ),
      initialRoute: widget.initialRoute,
      onGenerateRoute: (RouteSettings settings) => routes.getRouteView(settings.name, settings.arguments),
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
    super.dispose();
  }
}
