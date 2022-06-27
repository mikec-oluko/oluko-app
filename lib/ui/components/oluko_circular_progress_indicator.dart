import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/constants/theme.dart';

class OlukoCircularProgressIndicator extends StatefulWidget {
  final bool personalized;
  final double width;
  final Color color;

  OlukoCircularProgressIndicator({this.personalized = false, this.width = 1, this.color=OlukoColors.primary});

  @override
  _State createState() => _State();
}

class _State extends State<OlukoCircularProgressIndicator> {
  @override
  Widget build(BuildContext context) {
    return widget.personalized
        ? Center(
            child: CircularProgressIndicator(strokeWidth: widget.width, color: widget.color),
          )
        : Center(
            child: CircularProgressIndicator(strokeWidth: 1),
          );
  }
}
