import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

/// Segmented indeterminate progress bar
class SegmentedIndeterminateProgressbar extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  SegmentedIndeterminateProgressbar({this.max, this.progress, Key key}) : super(key: key);
  double max;
  double progress;

  @override
  _SegmentedIndeterminateProgressbarState createState() => _SegmentedIndeterminateProgressbarState();
}

class _SegmentedIndeterminateProgressbarState extends State<SegmentedIndeterminateProgressbar> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return OlukoNeumorphism.isNeumorphismDesign
        ? Neumorphic(
            style: OlukoNeumorphism.getNeumorphicStyleForCircleWatchWithShadows(), child: getStepProgress(widget.max, widget.progress))
        : getSegmentedProgressBar(widget.max, widget.progress);
  }

  Widget getStepProgress(double max, double progress) {
    return Stack(fit: StackFit.expand, children: [
      Neumorphic(
        style: OlukoNeumorphism.getNeumorphicStyleForInnerCircleWatch(),
        child: Container(
          decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.centerRight, colors: [
                OlukoNeumorphismColors.olukoNeumorphicSearchBarSecondColor,
                OlukoNeumorphismColors.olukoNeumorphicSearchBarFirstColor
              ], stops: [
                0.1,
                0.9
              ])),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: CircularStepProgressIndicator(
              roundedCap: (_, isSelected) => true,
              totalSteps: max.toInt(),
              width: 100,
              selectedStepSize: 20,
              unselectedStepSize: 20,
              gradientColor: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [
                OlukoNeumorphismColors.olukoNeumorphicSearchBarFirstColor,
                OlukoNeumorphismColors.olukoNeumorphicSearchBarFirstColor.withOpacity(0.8),
                OlukoNeumorphismColors.olukoNeumorphicSearchBarSecondColor,
                OlukoNeumorphismColors.olukoNeumorphicSearchBarSecondColor,
              ], stops: const [
                0.0,
                0.2,
                0.4,
                0.8
              ]),
              // selectedColor: OlukoColors.primary,
              currentStep: progress.toInt(),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Neumorphic(
                  style: OlukoNeumorphism.getNeumorphicStyleForInnerCircleWatch(),
                ),
              ),
            ),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(10.0),
        child: CircularStepProgressIndicator(
            roundedCap: (_, isSelected) => true,
            totalSteps: max.toInt(),
            selectedColor: OlukoColors.primary,
            unselectedColor: Colors.transparent,
            width: 100,
            selectedStepSize: 20,
            unselectedStepSize: 20,
            currentStep: progress.toInt(),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Neumorphic(
                style: OlukoNeumorphism.getNeumorphicStyleForInnerCircleWatch().copyWith(oppositeShadowLightSource: true),
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        OlukoNeumorphismColors.olukoNeumorphicSearchBarFirstColor,
                        OlukoNeumorphismColors.olukoNeumorphicSearchBarSecondColor,
                        OlukoNeumorphismColors.olukoNeumorphicSearchBarSecondColor,
                      ],
                      center: AlignmentDirectional(0.2, -0.35),
                      focal: AlignmentDirectional(0.8, 0.95),
                      radius: 0.95,
                      focalRadius: 0.2,
                      stops: [0.04, 0.8, 0.9],
                    ),
                  ),
                ),
              ),
            )),
      ),
    ]);
  }

  Widget getSegmentedProgressBar(double max, double progress) {
    return SfRadialGauge(axes: <RadialAxis>[
      // Create primary radial axis
      RadialAxis(
        minimum: 0,
        interval: 1,
        maximum: max,
        showLabels: false,
        showTicks: false,
        startAngle: 270,
        endAngle: 270,
        radiusFactor: 0.6,
        axisLineStyle: AxisLineStyle(
          thickness: 0.05,
          color: OlukoColors.grayColorSemiTransparent,
          thicknessUnit: GaugeSizeUnit.factor,
        ),
        pointers: <GaugePointer>[
          RangePointer(
            value: progress,
            width: 0.05,
            color: OlukoColors.primary,
            sizeUnit: GaugeSizeUnit.factor,
          )
        ],
      ),
      // Create secondary radial axis for segmented line
      RadialAxis(
        minimum: 0,
        interval: 1,
        maximum: max,
        showLabels: false,
        showTicks: true,
        showAxisLine: false,
        tickOffset: -0.05,
        offsetUnit: GaugeSizeUnit.factor,
        minorTicksPerInterval: 0,
        startAngle: 270,
        endAngle: 270,
        radiusFactor: 0.6,
        majorTickStyle: MajorTickStyle(length: 0.1, thickness: 5, lengthUnit: GaugeSizeUnit.factor, color: Colors.black),
      )
    ]);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
