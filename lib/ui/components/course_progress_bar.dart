import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';

class CourseProgressBar extends StatefulWidget {
  final Image imageCover;
  final double value;
  final bool isStartedClass;

  CourseProgressBar({this.imageCover, this.value, this.isStartedClass = false});

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<CourseProgressBar> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(15)),
        child: LinearProgressIndicator(
          value: widget.value,
          valueColor: AlwaysStoppedAnimation<Color>(OlukoNeumorphism.isNeumorphismDesign? OlukoColors.yellow:OlukoColors.primary),
          backgroundColor: OlukoNeumorphism.isNeumorphismDesign? widget.isStartedClass ? OlukoColors.taskCardBackground : Colors.grey[200]:Colors.white24,
        ));
  }
}
