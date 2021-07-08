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

  static String durationToString(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}
