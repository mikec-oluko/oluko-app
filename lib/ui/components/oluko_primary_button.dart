import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mvt_fitness/constants/theme.dart';

class OlukoPrimaryButton extends StatefulWidget {
  final Function() onPressed;
  final String title;
  final Color color;
  final Color textColor;
  final TextAlign textAlign;

  OlukoPrimaryButton(
      {this.title,
      this.onPressed,
      this.color,
      this.textColor = Colors.black,
      this.textAlign = TextAlign.center});

  @override
  _State createState() => _State();
}

class _State extends State<OlukoPrimaryButton> {
  Color buttonColor = OlukoColors.primary;
  @override
  Widget build(BuildContext context) {
    if (widget.color != null) {
      buttonColor = widget.color;
    }
    return Expanded(
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              primary: buttonColor, side: BorderSide(color: buttonColor)),
          onPressed: () => widget.onPressed(),
          child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                widget.title,
                textAlign: widget.textAlign,
                style: TextStyle(fontSize: 18, color: widget.textColor),
              ))),
    );
  }
}
