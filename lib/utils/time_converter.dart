import 'package:flutter/material.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class TimeConverter {
  static double fromSecondsToMilliSeconds(double seconds) {
    return (seconds * 1000);
  }

  static double fromMillisecondsToSeconds(int milliseconds) {
    return (milliseconds / 1000);
  }

  static String fromSecondsToStringFormat(double seconds) {
    String stringSeconds = seconds.toString();
    List<String> splittedSeconds = stringSeconds.split('.');
    String finalSeconds = splittedSeconds[0];
    if (finalSeconds.length == 1) {
      finalSeconds = "0" + finalSeconds;
    }
    String finalMilliseconds = splittedSeconds[1].substring(0, 2);
    return finalSeconds + ":" + finalMilliseconds;
  }

  static String fromMillisecondsToSecondsStringFormat(int milliseconds) {
    return fromSecondsToStringFormat(fromMillisecondsToSeconds(milliseconds));
  }

  static String toCourseDuration(int weeks, int classes, BuildContext context) {
    return weeks.toString() +
        " " +
        OlukoLocalizations.of(context).find('weeks') +
        ", " +
        classes.toString() +
        " " +
        OlukoLocalizations.of(context).find('classes');
  }
}
