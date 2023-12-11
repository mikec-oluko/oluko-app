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

  static String secondsToMinutes(double totalSeconds, {bool oneDigitMinute = false}) {
    int minutes = totalSeconds ~/ 60;
    num seconds = totalSeconds % 60;
    String stringSeconds = seconds.toString();
    List<String> splittedSeconds = stringSeconds.split('.');
    String finalSeconds = splittedSeconds[0];
    String minutesStr = '${(minutes < 10) ? oneDigitMinute ? '$minutes' : '0$minutes' : '$minutes'}:${(seconds < 10) ? '0$finalSeconds' : finalSeconds}';

    return minutesStr;
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
    String centisecond =
        ((duration.inMilliseconds / 10) - (duration.inSeconds % 60 * 100) - (duration.inMinutes * 60 * 100) - (duration.inHours * 60 * 60 * 100))
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

  static String returnDateAndTimeOnStringFormat({Timestamp dateToFormat, BuildContext context, String separator}) {
    final String ymdLocalized = DateFormat.yMd(Localizations.localeOf(context).languageCode).add_jm().format(dateToFormat.toDate());
    if (separator != null) ymdLocalized.replaceAll('/', '.');
    final dateSplitted = ymdLocalized.split(' ');
    dateSplitted[0] = '${dateSplitted[0]} |';
    if (MediaQuery.of(context).alwaysUse24HourFormat) {
      dateSplitted[1] = DateFormat.Hm(Localizations.localeOf(context).languageCode).format(dateToFormat.toDate());
      dateSplitted.removeAt(2);
    }
    return dateSplitted.join(' ');
  }

  static String returnTimeStringFormat(DateTime date, BuildContext context) {
    if (MediaQuery.of(context).alwaysUse24HourFormat) {
      return DateFormat.Hm().format(date);
    } else {
      return DateFormat('hh:mm a').format(date);
    }
  }

  static String returnDateOnStringFormat({Timestamp dateToFormat, BuildContext context, String separator}) {
    //date doc: https://pub.dev/documentation/intl/latest/intl/DateFormat-class.html
    //7/10/1996 5:08 PM
    final String ymdLocalized = DateFormat.yMd(Localizations.localeOf(context).languageCode).format(dateToFormat.toDate());
    if (separator != null) {
      ymdLocalized.replaceAll('/', separator);
    }
    return ymdLocalized;
  }

  static String getDateAndTimeOnStringFormat({Timestamp dateToFormat, BuildContext context}) {
    final String ymdLocalized = DateFormat.yMd(Localizations.localeOf(context).languageCode).add_jm().format(dateToFormat.toDate());
    ymdLocalized.replaceAll('/', '.');
    final dateSplitted = ymdLocalized.split(' ');
    dateSplitted[0] = '${dateSplitted[0]},';
    List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    String ret;
    if (dateSplitted.length > 2) {
      ret = dateSplitted[1] + " " + dateSplitted[2];
    } else {
      ret = dateSplitted[1];
    }
    String day = dateToFormat.toDate().day.toString();
    String year = dateToFormat.toDate().year.toString();
    String month = months[dateToFormat.toDate().month - 1];
    ret += ", " + day + " " + month + ", " + year;
    return ret;
  }
}
