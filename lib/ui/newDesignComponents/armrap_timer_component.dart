import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:oluko_app/utils/timer_utils.dart';

class ArmrapTimerComponent extends StatefulWidget {
  final Function() onTap;
  final double progressValue;
  final String duration;
  final int roundsValue;
  const ArmrapTimerComponent({this.onTap, this.progressValue, this.duration, this.roundsValue}) : super();

  @override
  State<ArmrapTimerComponent> createState() => _ArmrapTimerComponentState();
}

class _ArmrapTimerComponentState extends State<ArmrapTimerComponent> {
  static const double _progressIndicatorStroke = OlukoNeumorphism.isNeumorphismDesign ? 2 : 4;
  static const Color backgroundColor =
      OlukoNeumorphism.isNeumorphismDesign ? OlukoNeumorphismColors.olukoNeumorphicBackgroundDark : OlukoColors.grayColorSemiTransparent;
  static const Color getGreenOrCoral = OlukoNeumorphism.isNeumorphismDesign ? OlukoNeumorphismColors.olukoNeumorphicGreenWatchColor : OlukoColors.coral;
  bool animateTap = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          widget.onTap();
          setState(() {
            animateTap = true;
          });
        },
        child: SizedBox(
            width: TimerUtils.getProgressCircleSize(context),
            height: TimerUtils.getProgressCircleSize(context),
            child: _amrapTimerContent(widget.progressValue, widget.duration, widget.roundsValue)));
  }

  Stack _amrapTimerContent(double progressValue, String duration, int roundsValue) {
    return Stack(alignment: Alignment.center, children: [
      AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: animateTap ? OlukoColors.primary.withOpacity(0.5) : Colors.transparent,
        ),
        onEnd: () {
          setState(() {
            animateTap = false;
          });
        },
      ),
      AspectRatio(
          aspectRatio: 1,
          child:
              CircularProgressIndicator(strokeWidth: _progressIndicatorStroke, value: progressValue, color: getGreenOrCoral, backgroundColor: backgroundColor)),
      Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        if (OlukoNeumorphism.isNeumorphismDesign) const SizedBox.shrink() else TimerUtils.durationField(duration, OlukoColors.primary),
        const SizedBox(height: 12),
        TimerUtils.tapHereText(context),
        const SizedBox(height: 3),
        TimerUtils.forNextRoundText(context),
        if (OlukoNeumorphism.isNeumorphismDesign)
          const SizedBox(
            height: 10,
          )
        else
          const SizedBox.shrink(),
        if (OlukoNeumorphism.isNeumorphismDesign && roundsValue != null) TimerUtils.getRoundLabel(roundsValue) else const SizedBox.shrink(),
        if (!OlukoNeumorphism.isNeumorphismDesign) const SizedBox.shrink() else TimerUtils.durationField(duration, OlukoColors.primary),
      ])
    ]);
  }
}
