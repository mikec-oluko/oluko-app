import 'package:flutter/material.dart';
import 'package:oluko_app/screens/HomePage.dart';
import 'package:oluko_app/screens/Login.dart';
import 'package:oluko_app/screens/Profile.dart';
import 'package:oluko_app/screens/SignUpWithEmail.dart';
import 'package:oluko_app/screens/SignUp.dart';

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
        '/log-in': (context) => LoginPage()
      },
    );
  }
}
