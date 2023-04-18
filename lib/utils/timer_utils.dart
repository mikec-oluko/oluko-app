import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/animation_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/coach_request.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/SegmentedProgressBar/segmented_indeterminate_progressbar.dart';
import 'package:oluko_app/ui/components/countdown_overlay.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:oluko_app/utils/segment_clocks_utils.dart';

enum InitialTimerType { Start, End }

class TimerUtils {
  //CIRCULAR PROGRESS ELEMENTS
  static const double _olukoNeumorphicWatchSize = 300;
  static const double _olukoWatchFullSize = 240;
  static const double _olukoNeumorphicWatchProgressSize = 220;
  static const double _olukoWatchProgressSize = 180;
  static const double _watchHeight = OlukoNeumorphism.isNeumorphismDesign ? _olukoNeumorphicWatchProgressSize : _olukoWatchProgressSize;
  static const double _watchWidth = OlukoNeumorphism.isNeumorphismDesign ? _olukoNeumorphicWatchProgressSize : _olukoWatchProgressSize;
  static const double _roundWatchWidthWithKeyboard = OlukoNeumorphism.isNeumorphismDesign ? _olukoNeumorphicWatchSize : _olukoWatchFullSize;
  static const double _progressIndicatorStroke = OlukoNeumorphism.isNeumorphismDesign ? 2 : 4;
  static const Color getGreenOrCoral = OlukoNeumorphism.isNeumorphismDesign ? OlukoNeumorphismColors.olukoNeumorphicGreenWatchColor : OlukoColors.coral;
  static const Color getGreenOrSkyBlue = OlukoNeumorphism.isNeumorphismDesign ? OlukoNeumorphismColors.olukoNeumorphicGreenWatchColor : OlukoColors.skyblue;
  static const Color backgroundColor =
      OlukoNeumorphism.isNeumorphismDesign ? OlukoNeumorphismColors.olukoNeumorphicBackgroundDark : OlukoColors.grayColorSemiTransparent;
  static const _maxStepsForSegmentedClock = 50;
  static const double _valueForNoSegmentsOnClock = 100;
  static const double _segmentClockNoProgressValue = 0;

//CLOCKS
  static Widget initialTimer(InitialTimerType type, int round, int totalTime, int countDown, BuildContext context) {
    return Stack(alignment: Alignment.center, children: [
      SizedBox(
        width: getProgressCircleSize(context),
        height: getProgressCircleSize(context),
        child: AspectRatio(
            aspectRatio: 1,
            child: CircularProgressIndicator(
                strokeWidth: _progressIndicatorStroke, value: getProgress(totalTime, countDown), color: getGreenOrCoral, backgroundColor: backgroundColor)),
      ),
      Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(countDown.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Gilroy',
              fontSize: 80,
              fontWeight: FontWeight.bold,
              //fontStyle: FontStyle.italic,
              color: getGreenOrCoral,
            )),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(OlukoLocalizations.get(context, 'round') + "  ",
              textAlign: TextAlign.center, style: OlukoFonts.olukoSmallFont(customFontWeight: FontWeight.bold)),
          Text((round + 1).toString(), textAlign: TextAlign.center, style: OlukoFonts.olukoBigFont(customFontWeight: FontWeight.bold))
        ]),
        SizedBox(height: 2),
        Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Text(getRepsTimerText(type, context),
                textAlign: TextAlign.center,
                style: OlukoFonts.olukoMediumFont(
                    customFontWeight: FontWeight.bold, customColor: OlukoNeumorphism.isNeumorphismDesign ? OlukoColors.primary : OlukoColors.white)))
      ])
    ]);
  }

  static Widget roundsTimer(int totalRounds, int currentRound, [bool keyboardVisibilty = false]) => RotationTransition(
      turns: AlwaysStoppedAnimation(3 / 360),
      child: Container(
          //TODO: CHECK RESOLUTIONS WITH KEYBOARD
          height: () {
            if (keyboardVisibilty) return _roundWatchWidthWithKeyboard;
            return OlukoNeumorphism.isNeumorphismDesign ? 300.0 : 340.0;
          }(),
          width: () {
            if (keyboardVisibilty) return _roundWatchWidthWithKeyboard;
            return OlukoNeumorphism.isNeumorphismDesign ? 300.0 : 340.0;
          }(),
          child: getSegmentedProgressBar(
              totalRounds.toDouble() > 0 ? totalRounds.toDouble() : 1, currentRound.toDouble() <= totalRounds.toDouble() ? currentRound.toDouble() : 1)));

  static Widget getSegmentedProgressBar(double totalRounds, double currentRound) {
    if (totalRounds < _maxStepsForSegmentedClock) {
      return SegmentedIndeterminateProgressbar(
        max: totalRounds.toDouble() > 0 ? totalRounds.toDouble() : 1,
        progress: currentRound.toDouble() <= totalRounds.toDouble() ? currentRound.toDouble() : 1,
      );
    } else {
      return Stack(fit: StackFit.expand, children: [
        SegmentedIndeterminateProgressbar(
          max: _valueForNoSegmentsOnClock,
          progress: _segmentClockNoProgressValue,
        ),
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: CircularProgressIndicator(
              strokeWidth: 10,
              value: getProgressAscending(totalRounds.toInt(), currentRound.toInt()),
              color: OlukoColors.primary,
              backgroundColor: Colors.transparent),
        )
      ]);
    }
  }

  static Widget timeTimer(double progressValue, String duration, BuildContext context, [String counter, bool bothSide]) {
    return Container(
        child: SizedBox(
            width: getProgressCircleSize(context),
            height: getProgressCircleSize(context),
            child: Stack(alignment: Alignment.center, children: [
              AspectRatio(
                  aspectRatio: 1,
                  child: CircularProgressIndicator(
                      strokeWidth: _progressIndicatorStroke, value: progressValue, color: getGreenOrCoral, backgroundColor: backgroundColor)),
              Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                if (OlukoNeumorphism.isNeumorphismDesign) const Expanded(child: SizedBox()) else const SizedBox.shrink(),
                Text(duration,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'Gilroy', fontSize: OlukoNeumorphism.isNeumorphismDesign ? 35 : 25, fontWeight: FontWeight.bold, color: Colors.white)),
                if (counter != null)
                  OlukoNeumorphism.isNeumorphismDesign
                      ? neumorphicContentWithPadding(context, getTextLabel(OlukoLocalizations.get(context, 'countYour') + counter, context, true))
                      : getTextLabel(OlukoLocalizations.get(context, 'countYour') + counter, context, true)
                else
                  SizedBox(height: 5),
                if (bothSide) getTextLabel(OlukoLocalizations.get(context, 'rememberTo'), context, true) else const SizedBox.shrink(),
                if (bothSide) getTextLabel(OlukoLocalizations.get(context, 'switchSide'), context, false) else SizedBox(),
                if (OlukoNeumorphism.isNeumorphismDesign && counter != null)
                  const SizedBox(
                    height: 40,
                  )
                else
                  const Expanded(child: SizedBox()),
              ])
            ])));
  }

  static Widget completedTimer(BuildContext context, int rounds) {
    return OlukoNeumorphism.isNeumorphismDesign
        ? Container(
            child: SizedBox(
                height: _olukoNeumorphicWatchProgressSize,
                width: _olukoNeumorphicWatchProgressSize,
                child: Stack(alignment: Alignment.center, children: [
                  const AspectRatio(
                    aspectRatio: 1,
                    child: CircularProgressIndicator(
                      strokeWidth: _progressIndicatorStroke,
                      value: 1,
                      color: OlukoNeumorphismColors.olukoNeumorphicGreenWatchColor,
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Image(
                        image: AssetImage('assets/self_recording/completed_tick.png'),
                        width: 30,
                        height: 30,
                      ),
                      const SizedBox(height: 8),
                      Text(OlukoLocalizations.get(context, 'completed'),
                          textAlign: TextAlign.center,
                          style: OlukoFonts.olukoSuperBigFont(
                              customFontWeight: FontWeight.bold,
                              customColor: OlukoNeumorphism.isNeumorphismDesign ? OlukoNeumorphismColors.olukoNeumorphicGreenWatchColor : Colors.white)),
                      const SizedBox(height: 8),
                      if (rounds != null)
                        Text(rounds.toString() + " " + OlukoLocalizations.get(context, 'rounds'),
                            textAlign: TextAlign.center, style: OlukoFonts.olukoSuperBigFont(customFontWeight: FontWeight.bold)),
                    ],
                  )
                ])))
        : Container(
            child: SizedBox(
                height: _olukoWatchProgressSize,
                width: _olukoWatchProgressSize,
                child: Stack(alignment: Alignment.center, children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Image(image: AssetImage('assets/self_recording/completed_tick.png')),
                      const SizedBox(height: 8),
                      Text(OlukoLocalizations.get(context, 'completed'),
                          textAlign: TextAlign.center,
                          style: OlukoFonts.olukoSubtitleFont(
                              customFontWeight: FontWeight.bold,
                              customColor: OlukoNeumorphism.isNeumorphismDesign ? OlukoNeumorphismColors.olukoNeumorphicGreenWatchColor : Colors.white)),
                    ],
                  )
                ])));
  }

  static Widget pausedTimer(BuildContext context, [String duration]) {
    return Container(
        child: Stack(alignment: Alignment.center, children: [
      SizedBox(
        width: getProgressCircleSize(context),
        height: getProgressCircleSize(context),
        child: const AspectRatio(
            aspectRatio: 1,
            child: CircularProgressIndicator(
                strokeWidth: _progressIndicatorStroke,
                value: OlukoNeumorphism.isNeumorphismDesign ? 1 : 0,
                color: getGreenOrSkyBlue,
                backgroundColor: backgroundColor)),
      ),
      Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(OlukoNeumorphism.isNeumorphismDesign ? OlukoLocalizations.get(context, 'paused') : OlukoLocalizations.get(context, 'paused').toUpperCase(),
            textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: getGreenOrSkyBlue, fontFamily: 'Gilroy')),
        duration != null ? SizedBox(height: 12) : SizedBox(),
        duration != null
            ? Text(duration,
                textAlign: TextAlign.center,
                style:
                    TextStyle(fontSize: OlukoNeumorphism.isNeumorphismDesign ? 30 : 20, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Gilroy'))
            : SizedBox()
      ])
    ]));
  }

  static Widget restTimer(Widget addCounterValue, double progressValue, String duration, BuildContext context) {
    return Container(
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: getProgressCircleSize(context),
            height: getProgressCircleSize(context),
            child: AspectRatio(
                aspectRatio: 1,
                child: CircularProgressIndicator(
                    strokeWidth: _progressIndicatorStroke, value: progressValue, color: getGreenOrSkyBlue, backgroundColor: backgroundColor)),
          ),
          if (OlukoNeumorphism.isNeumorphismDesign && addCounterValue != null)
            Align(
              alignment: Alignment.center,
              child: addCounterValue,
            )
          else
            Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(OlukoNeumorphism.isNeumorphismDesign ? OlukoLocalizations.get(context, 'rest') : OlukoLocalizations.get(context, 'rest').toUpperCase(),
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: getGreenOrSkyBlue)),
              SizedBox(height: 12),
              Text(duration,
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Gilroy')),
            ]),
          if (OlukoNeumorphism.isNeumorphismDesign && addCounterValue != null)
            Positioned(
                bottom: ScreenUtils.smallScreen(context) ? ScreenUtils.height(context) * 0.11 : ScreenUtils.height(context) * 0.05,
                child: duration != null
                    ? Text(duration,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: OlukoNeumorphism.isNeumorphismDesign ? 20 : 15, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Gilroy'))
                    : SizedBox())
        ],
      ),
    );
  }

  static Widget repsTimer(Function() onTap, BuildContext context, [bool bothSide, String duration]) {
    final withOpacity = OlukoNeumorphismColors.finalGradientColorDark.withOpacity(0.0);
    return Container(
        child: SizedBox(
            height: _watchHeight,
            width: _watchWidth,
            child: GestureDetector(
                onTap: onTap,
                child: Stack(alignment: Alignment.center, children: [
                  SizedBox(
                    width: getProgressCircleSize(context),
                    height: getProgressCircleSize(context),
                    child: AspectRatio(
                        aspectRatio: 1,
                        child: CircularProgressIndicator(
                            strokeWidth: _progressIndicatorStroke, value: 0, color: OlukoColors.skyblue, backgroundColor: backgroundColor)),
                  ),
                  Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(OlukoLocalizations.get(context, 'tapHere'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: 'Gilroy',
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: OlukoNeumorphism.isNeumorphismDesign ? OlukoNeumorphismColors.olukoNeumorphicGreenWatchColor : OlukoColors.primary)),
                    SizedBox(height: 5),
                    Text(OlukoLocalizations.get(context, 'whenDone'),
                        textAlign: TextAlign.center,
                        style: OlukoFonts.olukoBigFont(
                            customFontWeight: FontWeight.w400, customColor: OlukoNeumorphism.isNeumorphismDesign ? OlukoColors.white : OlukoColors.primary)),
                    SizedBox(height: 5),
                    bothSide ? getTextLabel(OlukoLocalizations.get(context, 'rememberTo'), context, true) : SizedBox(),
                    bothSide ? getTextLabel(OlukoLocalizations.get(context, 'switchSide'), context, false) : SizedBox(),
                    duration == null ? const SizedBox.shrink() : durationField(duration, OlukoColors.lightOrange),
                  ])
                ]))));
  }

  static Widget AMRAPTimer(double progressValue, String duration, BuildContext context, Function() onTap, int roundsValue) {
    return GestureDetector(
        onTap: onTap,
        child: SizedBox(
            width: getProgressCircleSize(context),
            height: getProgressCircleSize(context),
            child: Stack(alignment: Alignment.center, children: [
              AspectRatio(
                  aspectRatio: 1,
                  child: CircularProgressIndicator(
                      strokeWidth: _progressIndicatorStroke, value: progressValue, color: getGreenOrCoral, backgroundColor: backgroundColor)),
              Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                OlukoNeumorphism.isNeumorphismDesign ? const SizedBox.shrink() : durationField(duration, OlukoColors.primary),
                const SizedBox(height: 12),
                Text(OlukoLocalizations.get(context, 'tapHere'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'Gilroy',
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: OlukoNeumorphism.isNeumorphismDesign ? OlukoNeumorphismColors.olukoNeumorphicGreenWatchColor : OlukoColors.primary)),
                SizedBox(height: 3),
                Text(OlukoLocalizations.get(context, 'forNextRound'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'Gilroy',
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: OlukoNeumorphism.isNeumorphismDesign ? OlukoColors.white : OlukoColors.primary)),
                OlukoNeumorphism.isNeumorphismDesign
                    ? SizedBox(
                        height: 10,
                      )
                    : const SizedBox.shrink(),
                OlukoNeumorphism.isNeumorphismDesign && roundsValue != null ? getRoundLabel(roundsValue) : const SizedBox.shrink(),
                !OlukoNeumorphism.isNeumorphismDesign ? const SizedBox.shrink() : durationField(duration, OlukoColors.primary),
              ])
            ])));
  }

  static Widget finalTimer(InitialTimerType type, int totalTime, int countDown, BuildContext context, [int round]) {
    return Stack(alignment: Alignment.center, children: [
      SizedBox(
        width: getProgressCircleSize(context),
        height: getProgressCircleSize(context),
        child: AspectRatio(
            aspectRatio: 1,
            child: CircularProgressIndicator(
                strokeWidth: _progressIndicatorStroke,
                value: getProgress(totalTime, countDown),
                color: OlukoColors.lightOrange,
                backgroundColor: backgroundColor)),
      ),
      Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(countDown.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Gilroy',
              fontSize: 80,
              fontWeight: FontWeight.bold,
              //fontStyle: FontStyle.italic,
              color: OlukoColors.lightOrange,
            )),
        if (round != null)
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(OlukoLocalizations.get(context, 'round') + "  ",
                textAlign: TextAlign.center, style: OlukoFonts.olukoSmallFont(customFontWeight: FontWeight.bold, customColor: OlukoColors.primary)),
            Text((round + 1).toString(),
                textAlign: TextAlign.center,
                style: OlukoFonts.olukoBigFont(
                  customFontWeight: FontWeight.bold,
                ))
          ]),
        SizedBox(height: 2),
        if (round != null)
          Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Text(getRepsTimerText(type, context),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Gilroy',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: OlukoNeumorphism.isNeumorphismDesign ? OlukoColors.primary : OlukoColors.white)))
      ])
    ]);
  }

//HELPER METHODS
  static Widget durationField(String duration, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Text(duration,
          textAlign: TextAlign.center,
          style:
              OlukoFonts.olukoSubtitleFont(customFontWeight: FontWeight.bold, customColor: OlukoNeumorphism.isNeumorphismDesign ? color : OlukoColors.white)),
    );
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

  static double getProgressAscending(int totalTime, int currentTime) {
    return currentTime / totalTime;
  }

  static Widget getTextLabel(String text, BuildContext context, bool padding) {
    return Padding(
        padding: padding ? EdgeInsets.only(top: 5) : EdgeInsets.only(top: 0),
        child: Text(text,
            textAlign: TextAlign.center,
            style: OlukoFonts.olukoMediumFont(
                customFontWeight: FontWeight.w300, customColor: OlukoNeumorphism.isNeumorphismDesign ? OlukoColors.primary : OlukoColors.coral)));
  }

  static Widget getRoundLabel(int round) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text('Round',
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'Gilroy', fontSize: 18, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: OlukoColors.primary)),
      SizedBox(width: 10),
      Text((round + 1).toString(),
          textAlign: TextAlign.center,
          style: TextStyle(
              fontFamily: 'Gilroy',
              fontSize: OlukoNeumorphism.isNeumorphismDesign ? 20 : 50,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              color: OlukoColors.white)),
    ]);
  }

  static Column neumorphicContentWithPadding(BuildContext context, Widget childrenContent) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 40),
          child: childrenContent,
        ),
      ],
    );
  }

  static startCountdown(WorkoutType workoutType, BuildContext context, Object arguments, int initialTimer) {
    BlocProvider.of<AnimationBloc>(context).playPauseAnimation();
    Navigator.pushNamed(context, routeLabels[RouteEnum.segmentClocks], arguments: arguments);
  }

  static double getProgressCircleSize(BuildContext context) {
    return ScreenUtils.smallScreen(context) ? 210 : 220;
  }
}
