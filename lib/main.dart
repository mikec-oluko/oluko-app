import 'package:flutter/material.dart';
import 'package:oluko_app/ui/screens/home_page.dart';
import 'package:oluko_app/ui/screens/Login.dart';
import 'package:oluko_app/ui/screens/Profile.dart';
import 'package:oluko_app/ui/screens/sign_up_with_email.dart';
import 'package:oluko_app/ui/screens/sign_up.dart';
import 'package:oluko_app/ui/screens/videos_home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

const OLUKO = 'Oluko';

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '${OLUKO}',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => MyHomePage(title: ''),
        '/sign-up': (context) => SignUpPage(),
        '/sign-up-with-email': (context) => SignUpWithMailPage(),
        '/profile': (context) => ProfilePage(),
        '/log-in': (context) => LoginPage(),
        '/videos': (context) => Home(
              title: "Videos",
              videoParent: null,
              videoParentPath: "",
            )
      },
    );
  }
}
