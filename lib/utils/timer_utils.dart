import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/SegmentedProgressBar/segmented_indeterminate_progressbar.dart';
import 'package:oluko_app/ui/components/countdown_overlay.dart';
import 'package:oluko_app/ui/screens/courses/segment_clocks.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

enum InitialTimerType { Start, End }

class TimerUtils {
  static Widget initialTimer(InitialTimerType type, int round, int totalTime, int countDown, BuildContext context) {
    return Stack(alignment: Alignment.center, children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 98.0),
        child: AspectRatio(
            aspectRatio: 1,
            child: CircularProgressIndicator(
                strokeWidth: OlukoNeumorphism.isNeumorphismDesign ? 2 : 4,
                value: getProgress(totalTime, countDown),
                color: OlukoColors.coral,
                backgroundColor: OlukoColors.grayColorSemiTransparent)),
      ),
      Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(countDown.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 80, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: OlukoColors.coral)),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(OlukoLocalizations.get(context, 'round') + "  ",
              textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
          Text((round + 1).toString(),
              textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white))
        ]),
        SizedBox(height: 2),
        Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Text(getRepsTimerText(type, context),
                textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)))
      ])
    ]);
  }

  static String getRepsTimerText(InitialTimerType type, BuildContext context) {
    if (type == InitialTimerType.Start) {
      return OlukoLocalizations.get(context, 'startsIn');
    } else {
      return OlukoLocalizations.get(context, 'endsIn');
    }
  }

  static double getProgress(int totalTime, int currentTime) {
    return 1 - (currentTime / totalTime);
  }

  static Widget roundsTimer(int totalRounds, int currentRound, [bool keyboardVisibilty = false]) => Container(
      height: () {
        if (keyboardVisibilty) return 240.0;
        return 340.0;
      }(),
      width: () {
        if (keyboardVisibilty) return 240.0;
        return 340.0;
      }(),
      child: SegmentedIndeterminateProgressbar(
        max: totalRounds.toDouble() > 0 ? totalRounds.toDouble() : 1,
        progress: currentRound.toDouble() <= totalRounds.toDouble() ? currentRound.toDouble() : 1,
      ));

  static Widget timeTimer(double progressValue, String duration, BuildContext context, [String counter, bool bothSide]) {
    return Container(
        child: SizedBox(
            height: OlukoNeumorphism.isNeumorphismDesign ? 245 : 180,
            width: OlukoNeumorphism.isNeumorphismDesign ? 245 : 180,
            child: Stack(alignment: Alignment.center, children: [
              AspectRatio(
                  aspectRatio: 1,
                  child: CircularProgressIndicator(
                      strokeWidth: OlukoNeumorphism.isNeumorphismDesign ? 2 : 4,
                      value: progressValue,
                      color: OlukoColors.coral,
                      backgroundColor: OlukoColors.grayColorSemiTransparent)),
              Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(duration,
                    textAlign: TextAlign.center, style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white)),
                counter != null ? getTextLabel(OlukoLocalizations.get(context, 'countYour') + counter, context, true) : SizedBox(),
                SizedBox(height: 5),
                bothSide ? getTextLabel(OlukoLocalizations.get(context, 'rememberTo'), context, true) : SizedBox(),
                bothSide ? getTextLabel(OlukoLocalizations.get(context, 'switchSide'), context, false) : SizedBox()
              ])
            ])));
  }

  static Widget getTextLabel(String text, BuildContext context, bool padding) {
    return Padding(
        padding: padding ? EdgeInsets.only(top: 5) : EdgeInsets.only(top: 0),
        child:
            Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w300, color: OlukoColors.coral)));
  }

  static Widget getRoundLabel(int round) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text('Round',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: OlukoColors.primary)),
      SizedBox(width: 10),
      Text((round + 1).toString(),
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: OlukoColors.white)),
    ]);
  }

  static Widget completedTimer(BuildContext context) {
    return Container(
        child: SizedBox(
            height: 180,
            width: 180,
            child: Stack(alignment: Alignment.center, children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image(image: AssetImage('assets/self_recording/completed_tick.png')),
                  SizedBox(height: 8),
                  Text(OlukoLocalizations.get(context, 'completed'),
                      textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
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
                      strokeWidth: OlukoNeumorphism.isNeumorphismDesign ? 2 : 4,
                      value: 0,
                      color: OlukoColors.skyblue,
                      backgroundColor: OlukoColors.grayColorSemiTransparent)),
              Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(OlukoLocalizations.get(context, 'paused').toUpperCase(),
                    textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: OlukoColors.skyblue)),
                duration != null ? SizedBox(height: 12) : SizedBox(),
                duration != null
                    ? Text(duration,
                        textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white))
                    : SizedBox()
              ])
            ])));
  }

  static Widget restTimer(double progressValue, String duration, BuildContext context) {
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
                      strokeWidth: OlukoNeumorphism.isNeumorphismDesign ? 2 : 4,
                      value: progressValue,
                      color: OlukoColors.skyblue,
                      backgroundColor: OlukoColors.grayColorSemiTransparent)),
              Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(OlukoLocalizations.get(context, 'rest').toUpperCase(),
                    textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: OlukoColors.skyblue)),
                SizedBox(height: 12),
                Text(duration,
                    textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white))
              ])
            ])));
  }

  static Widget repsTimer(Function() onTap, BuildContext context, [bool bothSide]) {
    return Container(
        child: SizedBox(
            height: OlukoNeumorphism.isNeumorphismDesign ? 245 : 180,
            width: OlukoNeumorphism.isNeumorphismDesign ? 245 : 180,
            child: GestureDetector(
                onTap: onTap,
                child: Stack(alignment: Alignment.center, children: [
                  AspectRatio(
                      aspectRatio: 1,
                      child: CircularProgressIndicator(
                          strokeWidth: OlukoNeumorphism.isNeumorphismDesign ? 2 : 4,
                          value: 0,
                          color: OlukoColors.skyblue,
                          backgroundColor: OlukoColors.grayColorSemiTransparent)),
                  Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(OlukoLocalizations.get(context, 'tapHere'),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: OlukoColors.primary)),
                    SizedBox(height: 5),
                    Text(OlukoLocalizations.get(context, 'whenDone'),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400, color: OlukoColors.primary)),
                    SizedBox(height: 5),
                    bothSide ? getTextLabel(OlukoLocalizations.get(context, 'rememberTo'), context, true) : SizedBox(),
                    bothSide ? getTextLabel(OlukoLocalizations.get(context, 'switchSide'), context, false) : SizedBox()
                  ])
                ]))));
  }

  static startCountdown(
      WorkoutType workoutType, BuildContext context, Object arguments, int initialTimer, int totalRounds, int currentRound,
      {Function() onShowAgainPressed, bool showPanel}) {
    return Navigator.of(context)
        .push(PageRouteBuilder(
            opaque: false,
            pageBuilder: (BuildContext context, _, __) => CountdownOverlay(
                  seconds: initialTimer != null ? initialTimer : 5,
                  totalRounds: totalRounds != null ? totalRounds : 1,
                  currentRound: currentRound != null ? currentRound : 0,
                  recording: workoutType == WorkoutType.segmentWithRecording,
                  onShowAgainPressed: onShowAgainPressed,
                  showPanel: showPanel,
                )))
        .then((value) => Navigator.pushNamed(context, routeLabels[RouteEnum.segmentClocks], arguments: arguments));
  }

  static Widget AMRAPTimer(double progressValue, String duration, BuildContext context, Function() onTap) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
            child: SizedBox(
                height: 180,
                width: 180,
                child: Stack(alignment: Alignment.center, children: [
                  AspectRatio(
                      aspectRatio: 1,
                      child: CircularProgressIndicator(
                          strokeWidth: OlukoNeumorphism.isNeumorphismDesign ? 2 : 4,
                          value: progressValue,
                          color: OlukoColors.coral,
                          backgroundColor: OlukoColors.grayColorSemiTransparent)),
                  Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(duration,
                        textAlign: TextAlign.center, style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white)),
                    SizedBox(height: 12),
                    Text(OlukoLocalizations.get(context, 'tapHere'),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: OlukoColors.primary)),
                    SizedBox(height: 3),
                    Text(OlukoLocalizations.get(context, 'forNextRound'),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: OlukoColors.primary))
                  ])
                ]))));
  }
}
