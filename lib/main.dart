import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/config/s3_settings.dart';
import 'package:oluko_app/routes.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'config/project_settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GlobalConfiguration().loadFromMap(projectSettings);
  GlobalConfiguration().loadFromMap(s3Settings);
  await Firebase.initializeApp();
  User alreadyLoggedUser = await AuthBloc().checkCurrentUser();
  final MyApp myApp = MyApp(
    initialRoute: alreadyLoggedUser == null ? '/sign-up' : '/',
  );
  if (GlobalConfiguration().getValue("build") == "local") {
    runApp(myApp);
  } else {
    await SentryFlutter.init(
      (options) {
        options.dsn = GlobalConfiguration().getValue("sentryDsn");
        options.environment = GlobalConfiguration().getValue("environment");
      },
      appRunner: () => runApp(myApp),
    );
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

  Widget build(BuildContext mainContext) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '${OLUKO}',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      initialRoute: widget.initialRoute,
      onGenerateRoute: (RouteSettings settings) =>
          routes.getRouteView(settings.name, settings.arguments),
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
