import 'package:flutter/material.dart';
import 'package:oluko_app/ui/screens/HomePage.dart';
import 'package:oluko_app/ui/screens/Login.dart';
import 'package:oluko_app/ui/screens/Profile.dart';
import 'package:oluko_app/ui/screens/SignUpWithEmail.dart';
import 'package:oluko_app/ui/screens/SignUp.dart';
import 'package:oluko_app/ui/screens/home.dart';

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
        '/videos': (context) => Home()
      },
    );
  }
}
