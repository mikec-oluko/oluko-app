import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/timer_utils.dart';

class RepTimerComponent extends StatefulWidget {
  final Function() onTap;
  final bool bothSide;
  final String duration;
  const RepTimerComponent({this.onTap, this.bothSide, this.duration}) : super();

  @override
  State<RepTimerComponent> createState() => _RepTimerComponentState();
}

class _RepTimerComponentState extends State<RepTimerComponent> {
  static const double _olukoNeumorphicWatchProgressSize = 220;
  static const double _olukoWatchProgressSize = 180;
  final double _watchHeight = OlukoNeumorphism.isNeumorphismDesign ? _olukoNeumorphicWatchProgressSize : _olukoWatchProgressSize;
  final double _watchWidth = OlukoNeumorphism.isNeumorphismDesign ? _olukoNeumorphicWatchProgressSize : _olukoWatchProgressSize;
  static const double _progressIndicatorStroke = OlukoNeumorphism.isNeumorphismDesign ? 2 : 4;
  static const Color backgroundColor =
      OlukoNeumorphism.isNeumorphismDesign ? OlukoNeumorphismColors.olukoNeumorphicBackgroundDark : OlukoColors.grayColorSemiTransparent;
  bool animateTap = false;
  @override
  Widget build(BuildContext context) {
    final withOpacity = OlukoNeumorphismColors.finalGradientColorDark.withOpacity(0.0);
    return Container(
      child: SizedBox(
        height: _watchHeight,
        width: _watchWidth,
        child: GestureDetector(
          onTap: () {
            widget.onTap();
            setState(() {
              animateTap = true;
            });
          },
          child: Stack(alignment: Alignment.center, children: [
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
            SizedBox(
              width: TimerUtils.getProgressCircleSize(context),
              height: TimerUtils.getProgressCircleSize(context),
              child: const AspectRatio(
                  aspectRatio: 1,
                  child:
                      CircularProgressIndicator(strokeWidth: _progressIndicatorStroke, value: 0, color: OlukoColors.skyblue, backgroundColor: backgroundColor)),
            ),
            Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              TimerUtils.tapHereText(context),
              const SizedBox(height: 5),
              TimerUtils.whenDoneText(context),
              const SizedBox(height: 5),
              if (widget.bothSide) TimerUtils.getTextLabel(OlukoLocalizations.get(context, 'rememberTo'), context, true) else const SizedBox(),
              if (widget.bothSide) TimerUtils.getTextLabel(OlukoLocalizations.get(context, 'switchSide'), context, false) else const SizedBox(),
              if (widget.duration == null) const SizedBox.shrink() else TimerUtils.durationField(widget.duration, OlukoColors.lightOrange),
            ])
          ]),
        ),
      ),
    );
  }
}
