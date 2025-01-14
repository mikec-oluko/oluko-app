import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';

class CourseProgressBar extends StatefulWidget {
  final Image imageCover;
  final double value;
  final bool isStartedClass;
  final Color color;

  CourseProgressBar({this.imageCover, this.value, this.isStartedClass = false, this.color});

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<CourseProgressBar> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(15)),
        child: LinearProgressIndicator(
          value: widget.value != null && !widget.value.isNaN ? widget.value : 0,
          valueColor: AlwaysStoppedAnimation<Color>(
              OlukoNeumorphism.isNeumorphismDesign ? widget.color ?? OlukoColors.yellow : OlukoColors.primary),
          backgroundColor: OlukoNeumorphism.isNeumorphismDesign
              ? widget.isStartedClass
                  ? OlukoColors.taskCardBackground
                  : Colors.grey[200]
              : Colors.white24,
        ));
  }
}
