import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/constants/Theme.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class CourseStepSection extends StatefulWidget {
  final int totalCourseSteps;
  final int currentCourseStep;

  CourseStepSection({this.totalCourseSteps, this.currentCourseStep});

  @override
  _State createState() => _State();
}

class _State extends State<CourseStepSection> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: getStepCircles(),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> getStepCircles() {
    List<Widget> circles = [];
    for (var i = 1; i <= widget.totalCourseSteps; i++) {
      circles.add(createCircleIcon(i == widget.currentCourseStep));
    }
    return circles;
  }

  Widget createCircleIcon(bool selected) {
    if (selected) {
      return Row(children: [
        Icon(
          Icons.circle,
          color: OlukoColors.primary,
          size: 5,
        ),
        SizedBox(width: 3)
      ]);
    } else {
      return Row(children: [
        Icon(
          Icons.circle,
          color: OlukoColors.white,
          size: 8,
        ),
        SizedBox(width: 3)
      ]);
    }
  }
}
