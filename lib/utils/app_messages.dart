import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class AppMessages {
  static void showSnackbar(context, message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }
}
