import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/ui/components/title_body.dart';

class AppNavigator {
  Future<void> returnToHome(BuildContext context) async {
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  static Future<bool> onWillPop(BuildContext context) async {
    return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            backgroundColor: Colors.black,
            title: TitleBody('Are you Sure?'),
            content: new Text('Do you want to exit Oluko MVT?', style: OlukoFonts.olukoBigFont()),
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
