import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/animation_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/notification_bloc.dart';
import 'package:oluko_app/blocs/project_configuration_bloc.dart';
import 'package:oluko_app/config/s3_settings.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/assessment_assignment.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/repositories/assessment_assignment_repository.dart';
import 'package:oluko_app/repositories/auth_repository.dart';
import 'package:oluko_app/repositories/user_repository.dart';
import 'package:oluko_app/routes.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/services/push_notification_service.dart';
import 'package:oluko_app/ui/newDesignComponents/animation.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/user_utils.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:oluko_app/config/project_settings.dart';
import 'services/route_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GlobalConfiguration().loadFromMap(projectSettings);
  GlobalConfiguration().loadFromMap(s3Settings);
  await Firebase.initializeApp();
  await initializeBackgroundNotifications();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  final User alreadyLoggedUser = await AuthBloc.checkCurrentUserStatic();
  final UserResponse alreadyLoggedUserResponse = await AuthRepository().retrieveLoginData();
  if(alreadyLoggedUserResponse != null){
    UserRepository().updateLastTimeOpeningApp(alreadyLoggedUserResponse);
  }
  final bool firstTime = await UserUtils.isFirstTime();
  final String route = await RouteService.getInitialRoute(alreadyLoggedUser, firstTime, alreadyLoggedUserResponse);
  final MyApp myApp = MyApp(
    initialRoute: route,
  );
  if (GlobalConfiguration().getString('build') == 'local') {
    runApp(myApp);
  } else {
    await SentryFlutter.init(
      (options) {
        options.dsn = GlobalConfiguration().getString('sentryDsn');
        options.environment = GlobalConfiguration().getString('environment');
        options.reportSilentFlutterErrors = true;
      },
      appRunner: () => runApp(myApp),
    );
  }
}

Future<void> initializeBackgroundNotifications() async {
    await AwesomeNotifications().initialize(
      'resource://drawable/icon',
      [
        NotificationChannel(channelKey: 'basic_channel',
                            channelName: 'Oluko push notifications',
                            channelDescription: 'Oluko push notifications',
                            importance: NotificationImportance.High,
                            channelShowBadge: true,
                            )
      ],
      debug: true,
    );
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  final String userAvatar = message.data['avatar'].toString();
  final NotificationContent notificationContent = NotificationContent(
        id: 10,
        channelKey: 'basic_channel',
        title: message.data['title']?.toString(),
        body: message.data['body'].toString(),
        notificationLayout: NotificationLayout.BigPicture,
  );
  if (Platform.isAndroid){
    notificationContent.largeIcon = userAvatar;
  }else{
    notificationContent.bigPicture = userAvatar;
  }
  AwesomeNotifications().createNotification(
    content: notificationContent,
  );
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
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey();
  @override
  Widget build(BuildContext mainContext) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    ProjectConfigurationBloc().getCourseConfiguration();
    return MultiBlocProvider(
      providers: [
        BlocProvider<AnimationBloc>(
          create: (mainContext) => AnimationBloc(),
        ),
        BlocProvider(
          create: (context) => NotificationBloc(),
        )
      ],
      child: MaterialApp(
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
        debugShowCheckedModeBanner: false,
        home: LayoutBuilder(
          builder: (context, constraints) {
            WidgetsBinding.instance.addPostFrameCallback((_) => _insertOverlay(context));
            return WillPopScope(
              onWillPop: () async {
                if (_navigatorKey.currentState.canPop()) {
                  !await _navigatorKey.currentState.maybePop();
                }
                return false;
              },
              child: Navigator(
                key: _navigatorKey,
                onGenerateRoute: (RouteSettings settings) => routes.getRouteView(settings.name, settings.arguments),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _insertOverlay(BuildContext context) {
    return Overlay.of(context).insert(
      OverlayEntry(builder: (context) {
        return HiFiveAnimation();
      }),
    );
  }
}
