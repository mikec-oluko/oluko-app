import 'package:flutter/material.dart';

class AppNavigator {
  Future<void> returnToHome(context) async {
    Navigator.popUntil(context, ModalRoute.withName('/'));
  }
}
