import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class AppNavigator {
  Future<void> returnToHome(context) async {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Navigator.popUntil(context, ModalRoute.withName('/'));
    });
  }
}
