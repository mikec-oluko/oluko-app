import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class SegmentStepSection extends StatefulWidget {
  final int totalSegmentStep;
  final int currentSegmentStep;
  final Function() onPressed;

  SegmentStepSection({this.totalSegmentStep, this.currentSegmentStep, this.onPressed});

  @override
  _State createState() => _State();
}

class _State extends State<SegmentStepSection> {
  @override
  Widget build(BuildContext context) {
    int totalSegmentStep = widget.totalSegmentStep;
    int currentSegmentStep = widget.currentSegmentStep;
    return Container(
      child: Padding(
        padding: const EdgeInsets.only(top: 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: getStepCircles(),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> getStepCircles() {
    final List<Widget> circles = [];
    for (var i = 1; i <= widget.totalSegmentStep; i++) {
      circles.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 10),
          child: Center(child: createCircleIcon(i == widget.currentSegmentStep)),
        ),
      );
    }
    return circles;
  }

  Widget createCircleIcon(bool selected) {
    if (OlukoNeumorphism.isNeumorphismDesign) {
      if (selected) {
        return const Icon(
          Icons.radio_button_checked,
          color: OlukoColors.primary,
          size: 15,
        );
      } else {
        return const Padding(
          padding: EdgeInsets.only(top: 1),
          child: Icon(
            Icons.circle,
            color: OlukoColors.grayColor,
            size: 10,
          ),
        );
      }
    } else {
      if (selected) {
        return Image.asset(
          'assets/courses/selected.png',
          scale: 2.5,
        );
      } else {
        return Image.asset(
          'assets/courses/unselected.png',
          scale: 2.5,
        );
      }
    }
  }
}
