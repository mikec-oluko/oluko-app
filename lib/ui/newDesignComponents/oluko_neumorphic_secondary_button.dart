import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:oluko_app/constants/theme.dart';

class OlukoNeumorphicSecondaryButton extends StatefulWidget {
  final Function() onPressed;
  final String title;
  // final Color color;
  final Color textColor;
  final TextAlign textAlign;
  final Widget icon;
  final bool thinPadding;
  final bool onlyIcon;
  final bool isDisabled;
  final bool isPrimary;
  final bool useBorder;
  final bool isExpanded;
  const OlukoNeumorphicSecondaryButton(
      {this.title,
      this.onPressed,
      this.thinPadding = false,
      // this.color,
      this.textColor = Colors.black,
      this.textAlign = TextAlign.center,
      this.icon,
      this.isDisabled = false,
      this.onlyIcon = false,
      this.isExpanded = true,
      this.useBorder = false,
      this.isPrimary = true})
      : super();

  @override
  _OlukoNeumorphicButtonState createState() => _OlukoNeumorphicButtonState();
}

class _OlukoNeumorphicButtonState extends State<OlukoNeumorphicSecondaryButton> {
  Color buttonColor = OlukoColors.primary;

  @override
  Widget build(BuildContext context) {
    // if (widget.color != null && !widget.isPrimary) {
    //   buttonColor = widget.color;
    // }
    // if (widget.isDisabled) {
    //   buttonColor = OlukoColors.disabled;
    // }
    return widget.isExpanded
        ? Expanded(
            child: secondaryButton(),
          )
        : secondaryButton();
  }

  NeumorphicButton secondaryButton() {
    return NeumorphicButton(
      onPressed: () {
        widget.onPressed != null ? widget.onPressed() : () {};
      },
      padding: EdgeInsets.all(10),
      style: OlukoNeumorphism.secondaryButtonStyle(
          useBorder: widget.useBorder,
          buttonShape: NeumorphicShape.flat,
          boxShape: NeumorphicBoxShape.stadium(),
          ligthShadow: true,
          darkShadow: true),
      child: Center(
        child: _textLabel(),
      ),
    );
  }

  Widget _textLabel() {
    if (widget.thinPadding) {
      return Text(
        widget.title,
        textAlign: widget.textAlign,
        style: TextStyle(fontSize: 14, color: widget.textColor),
      );
    } else {
      return Padding(
          padding: const EdgeInsets.all(15.0),
          child: Text(
            widget.title,
            textAlign: widget.textAlign,
            style: TextStyle(fontSize: 18, color: widget.textColor),
          ));
    }
  }
}
