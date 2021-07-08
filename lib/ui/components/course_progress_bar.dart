import 'package:flutter/material.dart';
import 'package:mvt_fitness/constants/theme.dart';

class CourseProgressBar extends StatefulWidget {
  final Image imageCover;
  final double value;

  CourseProgressBar({this.imageCover, this.value});

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
          valueColor: AlwaysStoppedAnimation<Color>(OlukoColors.primary),
          backgroundColor: Colors.white24,
        ));
  }
}
