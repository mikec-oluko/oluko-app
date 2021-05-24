import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_test_utils/image_test_utils.dart';
import 'package:oluko_app/ui/screens/SignUp.dart';

void main() {
  // Define a test. The TestWidgets function also provides a WidgetTester
  // to work with. The WidgetTester allows building and interacting
  // with widgets in the test environment.
  testWidgets('MyWidget has a title and message', (WidgetTester tester) async {
    provideMockedNetworkImages(() async {
      // Create the widget by telling the tester to build it.
      Widget testWidget = new MediaQuery(
          data: new MediaQueryData(),
          child: new MaterialApp(home: new SignUpPage()));
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      // Create the Finders.
      final titleFinder = find.text('Sign Up');
      final messageFinder = find.text('Sign Up to get started');
      final introMessageFinder =
          find.text('Create an account, You are just one step away!');
      final googleSignUpFinder = find.text('Sign In with Google');
      final facebookSignUpFinder = find.text('Sign In with Facebook');
      final signUpButtonTextFinder = find.text('SIGN UP WITH EMAIL');

      // Use the `findsOneWidget` matcher provided by flutter_test to
      // verify that the Text widgets appear exactly once in the widget tree.
      // expect(titleFinder, findsOneWidget);
      expect(messageFinder, findsOneWidget);
      // expect(introMessageFinder, findsOneWidget);
      // expect(googleSignUpFinder, findsOneWidget);
      // expect(facebookSignUpFinder, findsOneWidget);
      // expect(signUpButtonTextFinder, findsOneWidget);
      //
    });
  });

  // testWidgets('SignUp has a Sign up with Email button',
  //     (WidgetTester tester) async {
  //   provideMockedNetworkImages(() async {
  //     Widget testWidget = new MediaQuery(
  //         data: new MediaQueryData(),
  //         child: new MaterialApp(home: new SignUpPage()));
  //     await tester.pumpWidget(testWidget);
  //     await tester.pumpAndSettle(const Duration(seconds: 2));

  //     final signUpButtonTextFinder = find.text('SIGN UP WITH EMAIL');
  //     expect(signUpButtonTextFinder, findsOneWidget);

  //     var elevatedButtons = find.byWidgetPredicate(
  //       (Widget widget) => widget is ElevatedButton,
  //       description: 'widget elevated button',
  //     );

  //     expect(elevatedButtons, findsOneWidget);
  //     // elevatedButtons.any((element) =>
  //     //     element.widget.toStringDeep().contains("/sign-up-with-email") &&
  //     //     element.widget.toStringDeep().contains("SIGN UP WITH EMAIL"));
  //   });
  // });

  // testWidgets('SignUp has a Sign up with Google button',
  //     (WidgetTester tester) async {
  //   provideMockedNetworkImages(() async {
  //     Widget testWidget = new MediaQuery(
  //         data: new MediaQueryData(),
  //         child: new MaterialApp(home: new SignUpPage()));
  //     await tester.pumpWidget(testWidget);
  //     await tester.pumpAndSettle(const Duration(seconds: 2));

  //     final signUpButtonTextFinder = find.text('Sign In with Google');
  //     expect(signUpButtonTextFinder, findsOneWidget);

  //     var signUpButtonFinder = find.byWidgetPredicate(
  //       (Widget widget) => widget is OutlinedButton,
  //       description: 'widget outlined button',
  //     );

  //     expect(signUpButtonTextFinder, findsOneWidget);
  //     expect(signUpButtonFinder, findsWidgets);
  //     // elevatedButtons.any((element) =>
  //     //     element.widget.toStringDeep().contains("/sign-up-with-email") &&
  //     //     element.widget.toStringDeep().contains("SIGN UP WITH EMAIL"));
  //   });
  // });
}

class _MyHttpOverrides extends HttpOverrides {}
