import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class SnackbarService {
  static void showSnackbar(context, message) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
      ));
    });
  }
}
