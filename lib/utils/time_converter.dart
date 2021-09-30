import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60).toInt());
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60).toInt());
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

  static String toClassProgress(int currentClass, int totalClasses, BuildContext context) {
    return OlukoLocalizations.of(context).find('class') +
        " " +
        (currentClass + 1).toString() +
        " " +
        OlukoLocalizations.of(context).find('of') +
        " " +
        totalClasses.toString();
  }

  static String returnDateAndTimeOnStringFormat({Timestamp dateToFormat, BuildContext context}) {
    //date doc: https://pub.dev/documentation/intl/latest/intl/DateFormat-class.html
    //7/10/1996 5:08 PM
    final String ymdLocalized =
        DateFormat.yMd(Localizations.localeOf(context).languageCode).add_jm().format(dateToFormat.toDate()).replaceAll('/', '.');
    final dateSplitted = ymdLocalized.split(' ');
    dateSplitted[0] = '${dateSplitted[0]} |';
    return dateSplitted.join(' ');
  }
}
