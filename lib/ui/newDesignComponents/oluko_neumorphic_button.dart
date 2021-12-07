import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:oluko_app/constants/theme.dart';

class OlukoNeumorphicButton extends StatefulWidget {
  final Function() onPressed;
  final String title;
  final Color color;
  final Color textColor;
  final TextAlign textAlign;
  final Widget icon;
  final bool thinPadding;
  final bool isDisabled;
  final bool isPrimary;
  final bool useBorder;
  const OlukoNeumorphicButton(
      {this.title,
      this.onPressed,
      this.thinPadding = false,
      this.color,
      this.textColor = Colors.black,
      this.textAlign = TextAlign.center,
      this.icon,
      this.isDisabled = false,
      this.useBorder = false,
      this.isPrimary = true})
      : super();

  @override
  _OlukoNeumorphicButtonState createState() => _OlukoNeumorphicButtonState();
}

class _OlukoNeumorphicButtonState extends State<OlukoNeumorphicButton> {
  Color buttonColor = OlukoColors.primary;

  @override
  Widget build(BuildContext context) {
    if (widget.color != null && !widget.isPrimary) {
      buttonColor = widget.color;
    }
    if (widget.isDisabled) {
      buttonColor = OlukoColors.disabled;
    }
    return Expanded(
      child: NeumorphicButton(
        onPressed: () {
          print('working..');
        },
        padding: EdgeInsets.all(10),
        style: OlukoNeumorphism.neumorphicStyle(
            useBorder: widget.useBorder,
            backgroundColor: widget.color,
            buttonShape: NeumorphicShape.convex,
            boxShape: NeumorphicBoxShape.stadium(),
            ligthShadow: false,
            darkShadow: true),
        child: Center(
          child: _textLabel(),
        ),
      ),
    );
  }

  Widget _textLabel() {
    if (widget.thinPadding) {
      return Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Text(
            widget.title,
            textAlign: widget.textAlign,
            style: TextStyle(fontSize: 18, color: OlukoColors.white),
          ));
    } else {
      return Padding(
          padding: const EdgeInsets.all(15.0),
          child: Text(
            widget.title,
            textAlign: widget.textAlign,
            style: TextStyle(fontSize: 18, color: OlukoColors.white),
          ));
    }
  }
}
