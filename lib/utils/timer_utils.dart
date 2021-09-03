import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/IntervalProgressBarLib/interval_progress_bar.dart';
import 'package:oluko_app/ui/components/countdown_overlay.dart';
import 'package:oluko_app/ui/screens/courses/segment_clocks.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

enum InitialTimerType { Start, End }

class TimerUtils {
  static Widget initialTimer(InitialTimerType type, int round, int totalTime,
      int countDown, BuildContext context) {
    return Stack(alignment: Alignment.center, children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 98.0),
        child: AspectRatio(
            aspectRatio: 1,
            child: CircularProgressIndicator(
                value: getProgress(totalTime, countDown),
                // color: OlukoColors.coral,
                backgroundColor: OlukoColors.grayColorSemiTransparent)),
      ),
      Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(countDown.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 80,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                color: OlukoColors.coral)),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(OlukoLocalizations.of(context).find('round') + "  ",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          Text(round.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white))
        ]),
        SizedBox(height: 2),
        Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Text(getRepsTimerText(type, context),
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)))
      ])
    ]);
  }

  static String getRepsTimerText(InitialTimerType type, BuildContext context) {
    if (type == InitialTimerType.Start) {
      return OlukoLocalizations.of(context).find('startsIn');
    } else {
      return OlukoLocalizations.of(context).find('endsIn');
    }
  }

  static double getProgress(int totalTime, int currentTime) {
    return 1 - (currentTime / totalTime);
  }

  static Widget roundsTimer(int totalRounds, int currentRound) =>
      IntervalProgressBar(
        direction: IntervalProgressDirection.circle,
        max: totalRounds,
        progress: currentRound - 1,
        intervalSize: 4,
        size: Size(200, 200),
        highlightColor: OlukoColors.primary,
        defaultColor: OlukoColors.grayColorSemiTransparent,
        intervalColor: Colors.transparent,
        intervalHighlightColor: Colors.transparent,
        reverse: true,
        radius: 0,
        intervalDegrees: 5,
        strokeWith: 5,
      );

  static Widget timeTimer(
      double progressValue, String duration, BuildContext context,
      [String counter]) {
    return Container(
        child: SizedBox(
            height: 180,
            width: 180,
            child: Stack(alignment: Alignment.center, children: [
              AspectRatio(
                  aspectRatio: 1,
                  child: CircularProgressIndicator(
                      value: progressValue,
                      color: OlukoColors.coral,
                      backgroundColor: OlukoColors.grayColorSemiTransparent)),
              Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(duration,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                counter != null
                    ? Padding(
                        padding: EdgeInsets.only(top: 5),
                        child: Text(
                            OlukoLocalizations.of(context).find('countYour') +
                                counter,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w300,
                                color: OlukoColors.coral)))
                    : SizedBox()
              ])
            ])));
  }

  static Widget getEMOMRounds(int round) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text('Round',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              color: OlukoColors.primary)),
      SizedBox(width: 10),
      Text(round.toString(),
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 50,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              color: OlukoColors.white)),
    ]);
  }

  static Widget completedTimer(
      double progressValue, String duration, BuildContext context) {
    return Container(
        child: SizedBox(
            height: 180,
            width: 180,
            child: Stack(alignment: Alignment.center, children: [
              AspectRatio(
                  aspectRatio: 1,
                  child: CircularProgressIndicator(
                      value: progressValue,
                      color: OlukoColors.coral,
                      backgroundColor: OlukoColors.grayColorSemiTransparent)),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image(
                      image: AssetImage(
                          'assets/self_recording/completed_tick.png')),
                  SizedBox(height: 8),
                  Text(OlukoLocalizations.of(context).find('completed'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ],
              )
            ])));
  }

  static Widget pausedTimer(BuildContext context, [String duration]) {
    return Container(
        child: SizedBox(
            height: 180,
            width: 180,
            child: Stack(alignment: Alignment.center, children: [
              AspectRatio(
                  aspectRatio: 1,
                  child: CircularProgressIndicator(
                      value: 0,
                      // color: OlukoColors.skyblue,
                      backgroundColor: OlukoColors.grayColorSemiTransparent)),
              Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(
                    OlukoLocalizations.of(context).find('paused').toUpperCase(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: OlukoColors.skyblue)),
                duration != null ? SizedBox(height: 12) : SizedBox(),
                duration != null
                    ? Text(duration,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white))
                    : SizedBox()
              ])
            ])));
  }

  static Widget restTimer(
      double progressValue, String duration, BuildContext context) {
    //double ellipseScale = 4.5;
    return Container(
        child: SizedBox(
            height: 180,
            width: 180,
            child: Stack(alignment: Alignment.center, children: [
              /*Image.asset(
                'assets/courses/ellipse_1.png',
                scale: ellipseScale,
              ),
              Image.asset(
                'assets/courses/ellipse_2.png',
                scale: ellipseScale,
              ),
              Image.asset(
                'assets/courses/ellipse_3.png',
                scale: ellipseScale,
              ),*/
              AspectRatio(
                  aspectRatio: 1,
                  child: CircularProgressIndicator(
                      value: progressValue,
                      // color: OlukoColors.skyblue,
                      backgroundColor: OlukoColors.grayColorSemiTransparent)),
              Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(OlukoLocalizations.of(context).find('rest').toUpperCase(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: OlukoColors.skyblue)),
                SizedBox(height: 12),
                Text(duration,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white))
              ])
            ])));
  }

  static Widget repsTimer(Function() onTap, BuildContext context) {
    return Container(
        child: SizedBox(
            height: 180,
            width: 180,
            child: GestureDetector(
                onTap: onTap,
                child: Stack(alignment: Alignment.center, children: [
                  AspectRatio(
                      aspectRatio: 1,
                      child: CircularProgressIndicator(
                          value: 0,
                          // color: OlukoColors.skyblue,
                          backgroundColor:
                              OlukoColors.grayColorSemiTransparent)),
                  Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(OlukoLocalizations.of(context).find('tapHere'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: OlukoColors.primary)),
                        SizedBox(height: 5),
                        Text(OlukoLocalizations.of(context).find('whenDone'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: OlukoColors.primary))
                      ])
                ]))));
  }

  static startCountdown(WorkoutType workoutType, BuildContext context,
      Object arguments, int initialTimer, int totalRounds, int currentRound) {
    return Navigator.of(context)
        .push(PageRouteBuilder(
            opaque: false,
            pageBuilder: (BuildContext context, _, __) => CountdownOverlay(
                  seconds: initialTimer != null ? initialTimer : 5,
                  totalRounds: totalRounds,
                  currentRound: currentRound,
                  recording: workoutType == WorkoutType.segmentWithRecording,
                )))
        .then((value) => Navigator.pushNamed(
            context, routeLabels[RouteEnum.segmentClocks],
            arguments: arguments));
  }

  static Widget AMRAPTimer(
      double progressValue, String duration, BuildContext context) {
    return Container(
        child: SizedBox(
            height: 180,
            width: 180,
            child: Stack(alignment: Alignment.center, children: [
              AspectRatio(
                  aspectRatio: 1,
                  child: CircularProgressIndicator(
                      value: progressValue,
                      color: OlukoColors.coral,
                      backgroundColor: OlukoColors.grayColorSemiTransparent)),
              Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(duration,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                        Text(OlukoLocalizations.of(context).find('tapHere'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: OlukoColors.primary)),
                        SizedBox(height: 5),
                        Text(OlukoLocalizations.of(context).find('forNextRound'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: OlukoColors.primary))
              ])
            ])));
  }
}
