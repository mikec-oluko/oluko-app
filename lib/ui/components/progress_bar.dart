import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:oluko_app/constants/theme.dart';

class ProgressBar extends StatefulWidget {
  final String processPhase;
  final double progress;
  ProgressBar({this.processPhase, this.progress});

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<ProgressBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: OlukoNeumorphism.isNeumorphismDesign ? OlukoNeumorphismColors.olukoNeumorphicBackgroundLight : OlukoColors.black,
      child: Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
        Container(
          margin: EdgeInsets.only(bottom: 25.0),
          child: Text(
            widget.processPhase,
            style: TextStyle(
              color: OlukoColors.white,
            ),
          ),
        ),
        LinearProgressIndicator(
          value: widget.progress,
        )
      ]),
    );
  }
}
