import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mvt_fitness/constants/Theme.dart';
import 'package:mvt_fitness/utils/oluko_localizations.dart';

class SegmentStepSection extends StatefulWidget {
  final int totalSegmentStep;
  final int currentSegmentStep;
  final Function() onPressed;

  SegmentStepSection(
      {this.totalSegmentStep, this.currentSegmentStep, this.onPressed});

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
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${OlukoLocalizations.of(context).find('segment')} $currentSegmentStep/$totalSegmentStep',
                  style: OlukoFonts.olukoMediumFont(),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: getStepCircles(),
              ),
            )
          ],
        ),
      ),
    );
  }

  List<Widget> getStepCircles() {
    List<Widget> circles = [];
    for (var i = 1; i <= widget.totalSegmentStep; i++) {
      circles.add(createCircleIcon(i == widget.currentSegmentStep));
    }
    return circles;
  }

  Widget createCircleIcon(bool selected) {
    if (selected) {
      return Icon(
        Icons.circle,
        color: Colors.white,
        size: 15,
      );
    } else {
      return Icon(
        Icons.adjust,
        color: Colors.white,
        size: 15,
      );
    }
  }
}
