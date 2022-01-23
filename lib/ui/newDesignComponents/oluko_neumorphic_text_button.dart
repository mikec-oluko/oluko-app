import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/constants/theme.dart';

class OlukoNeumorphicTextButton extends StatefulWidget {
  final Function() onPressed;
  final String title;
  final bool thinPadding;
  final Color color;

  OlukoNeumorphicTextButton({this.title, this.thinPadding = false, this.onPressed, this.color});

  @override
  _State createState() => _State();
}

class _State extends State<OlukoNeumorphicTextButton> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: GestureDetector(
      onTap: () => widget.onPressed(),
      child: Text(
        widget.title,
        style: TextStyle(fontSize: 18, color: widget.color == null ? OlukoColors.grayColor : widget.color),
      ),
    ));
  }
}
