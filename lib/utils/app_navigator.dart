import 'package:flutter/material.dart';
import 'package:mvt_fitness/constants/Theme.dart';
import 'package:mvt_fitness/ui/components/title_body.dart';

class AppNavigator {
  Future<void> returnToHome(context) async {
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  static Future<bool> onWillPop(context) async {
    return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            backgroundColor: Colors.black,
            title: TitleBody('Are you Sure?'),
            content: new Text('Do you want to exit Oluko MVT?',
                style: OlukoFonts.olukoBigFont()),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: new Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }
}
