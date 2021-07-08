import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/constants/theme.dart';

class OlukoPrimaryButton extends StatefulWidget {
  final Function() onPressed;
  final String title;
  final Color color;
  final Color textColor;
  final TextAlign textAlign;
  final Widget icon;

  OlukoPrimaryButton(
      {this.title,
      this.onPressed,
      this.color,
      this.textColor = Colors.black,
      this.textAlign = TextAlign.center,
      this.icon});

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
    return widget.icon == null
        ? Expanded(
            child: ElevatedButton(
                style: _buttonStyle(),
                onPressed: () => widget.onPressed(),
                child: _textLabel()),
          )
        : Expanded(
            child: ElevatedButton.icon(
                style: _buttonStyle(),
                onPressed: () => widget.onPressed(),
                icon: widget.icon,
                label: _textLabel()),
          );
  }

  _buttonStyle() {
    return ElevatedButton.styleFrom(
        primary: buttonColor, side: BorderSide(color: buttonColor));
  }

  _textLabel() {
    return Padding(
        padding: const EdgeInsets.all(15.0),
        child: Text(
          widget.title,
          textAlign: widget.textAlign,
          style: TextStyle(fontSize: 18, color: widget.textColor),
        ));
  }
}
