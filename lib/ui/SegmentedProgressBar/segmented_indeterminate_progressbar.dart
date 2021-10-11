import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

/// Segmented indeterminate progress bar
class SegmentedIndeterminateProgressbar extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  SegmentedIndeterminateProgressbar({this.max, this.progress, Key key})
      : super(key: key);

  double max;
  double progress;

  @override
  _SegmentedIndeterminateProgressbarState createState() =>
      _SegmentedIndeterminateProgressbarState();
}

class _SegmentedIndeterminateProgressbarState
    extends State<SegmentedIndeterminateProgressbar>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return getSegmentedProgressBar(widget.max, widget.progress);
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
        majorTickStyle: MajorTickStyle(
            length: 0.1,
            thickness: 5,
            lengthUnit: GaugeSizeUnit.factor,
            color: Colors.black),
      )
    ]);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
