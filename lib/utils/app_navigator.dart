import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/title_body.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class AppNavigator {
  Future<void> returnToHome(BuildContext context) async {
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  Future<void> goToAssessmentVideos(BuildContext context) async {
    Navigator.pushNamedAndRemoveUntil(context, routeLabels[RouteEnum.assessmentVideos], (route) => false, arguments: {'isFirstTime': true});
  }

  static Future<bool> onWillPop(BuildContext context) async {
    if (Platform.isAndroid) {
      SystemNavigator.pop();
    } else if (Platform.isIOS) {
      exit(0);
    }
    //return showExitPopup(context);
  }

  static Future<bool> showExitPopup(BuildContext context) async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.black,
            title: TitleBody(OlukoLocalizations.get(context, 'exitConfirmationTitle')),
            content: Text(OlukoLocalizations.get(context, 'exitConfirmationBody'), style: OlukoFonts.olukoBigFont()),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  OlukoLocalizations.get(context, 'no'),
                ),
              ),
              TextButton(
                onPressed: () => {if (Platform.isAndroid) SystemNavigator.pop() else if (Platform.isIOS) exit(0)},
                child: Text(
                  OlukoLocalizations.get(context, 'yes'),
                ),
              ),
            ],
          ),
        )) ??
        false;
  }
}
