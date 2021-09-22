import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/ui/components/title_body.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class AppNavigator {
  Future<void> returnToHome(BuildContext context) async {
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  static Future<bool> onWillPop(BuildContext context) async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.black,
            title: TitleBody('Are you Sure?'),
            content: Text('Do you want to exit Oluko MVT?', style: OlukoFonts.olukoBigFont()),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  OlukoLocalizations.of(context).find('no'),
                ),
              ),
              TextButton(
                onPressed: () => {if (Platform.isAndroid) SystemNavigator.pop() else if (Platform.isIOS) exit(0)},
                child: Text(
                  OlukoLocalizations.of(context).find('yes'),
                ),
              ),
            ],
          ),
        )) ??
        false;
  }
}
