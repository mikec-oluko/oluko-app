import 'package:cloud_firestore/cloud_firestore.dart';
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

  //FORMAT TIME FUNCTION
  String formatTimeWithCentiSeconds(Duration duration) {
    String minutes = (duration.inMinutes).toString().padLeft(2, '0');
    String seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    String centisecond = ((duration.inMilliseconds / 10) -
            (duration.inSeconds % 60 * 100) -
            (duration.inMinutes * 60 * 100) -
            (duration.inHours * 60 * 60 * 100))
        .round()
        .toString()
        .padLeft(2, '0');
    return '$minutes:$seconds:$centisecond';
  }

  static String durationToString(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
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

  static String returnDateAndTimeOnStringFormat({Timestamp dateToFormat}) {
    String dateToReturnAsString;
    String date =
        dateToFormat.toDate().toString().split(" ")[0].replaceAll("-", ".");
    String hour = dateToFormat.toDate().toString().split(" ")[1].split(".")[0];
    hour = hour.replaceRange(hour.lastIndexOf(":"), hour.length, "");
    dateToReturnAsString = date + " | " + hour;
    return dateToReturnAsString;
  }
}
