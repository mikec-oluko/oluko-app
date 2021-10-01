import 'package:flutter/material.dart';
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
}
