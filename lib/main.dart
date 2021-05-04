import 'package:flutter/material.dart';
import 'package:oluko_app/screens/home-page.dart';
import 'package:oluko_app/screens/profile.dart';
import 'package:oluko_app/screens/sign-up-with-mail.dart';
import 'package:oluko_app/screens/sign-up.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => MyHomePage(title: ''),
        '/sign-up': (context) => SignUpPage(),
        '/sign-up-with-email': (context) => SignUpWithMailPage(),
        '/profile': (context) => ProfilePage()
      },
    );
  }
}
