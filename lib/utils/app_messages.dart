import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class AppMessages {
  static void showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  static void showSnackbarTranslated(BuildContext context, String translationKey) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(OlukoLocalizations.get(context, translationKey)),
    ));
  }

  void showHiFiveSentDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          Future.delayed(const Duration(seconds: 2), () {
            Navigator.of(context).pop(true);
          });
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/profile/hiFive_primary.png'),
              const Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  'Hi5 Sent!',
                  style: TextStyle(fontSize: 23, color: OlukoColors.primary, fontWeight: FontWeight.bold),
                ),
              )
            ],
          );
        });
  }
}
