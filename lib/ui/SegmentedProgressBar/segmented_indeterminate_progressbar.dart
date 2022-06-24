import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'dart:math' as math;

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

  double updatePaddingForSteps(int maxSteps) {
    // TODO: VITO
    /**
       * Esta funcion va a determinar el padding entre cada segmento del reloj
       * manteniendo siempre la misma distancia aprox
       * Esos son los rangos donde el padding se puede romper/ver mal (como pasaba con 28)
       * Se llama en el reloj, con el valor max de total steps
       * Si queres podes hacer un refactor, yo trate de dejarlo claro
       * math.pi/25 es el valor que encontre mas compatile para los menores a 34 segm
       * Si en tu cel se ve diferente tendremos que cambiarlo
       */
    double defaultStepPadding = math.pi / 25;
    if (maxSteps >= 34 && maxSteps <= 38) {
      defaultStepPadding = math.pi / 12;
    }
    if (maxSteps >= 38 && maxSteps <= 42) {
      defaultStepPadding = math.pi / 15;
    }
    if (maxSteps > 42 && maxSteps <= 46) {
      defaultStepPadding = math.pi / 18;
    }
    if (maxSteps > 46 && maxSteps <= 50) {
      defaultStepPadding = math.pi / 20;
    }
    return defaultStepPadding;
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
            padding: EdgeInsets.all(10),
            child: CircularStepProgressIndicator(
              roundedCap: (_, isSelected) => true,
              // TODO: VITO: ACA SE PIDE EL PADDING
              padding: updatePaddingForSteps(max.toInt()),
              totalSteps: max.toInt(),
              width: 100,
              selectedStepSize: 10,
              unselectedStepSize: 10,
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
            padding: updatePaddingForSteps(max.toInt()),
            roundedCap: (_, isSelected) => true,
            totalSteps: max.toInt(),
            selectedColor: OlukoColors.primary,
            unselectedColor: Colors.transparent,
            width: 100,
            selectedStepSize: 10,
            unselectedStepSize: 10,
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
        majorTickStyle: MajorTickStyle(length: 0.1, thickness: 5, lengthUnit: GaugeSizeUnit.factor, color: OlukoColors.black),
      )
    ]);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
