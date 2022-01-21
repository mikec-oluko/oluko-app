import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:oluko_app/constants/theme.dart';

class OlukoNeumorphicPrimaryButton extends StatefulWidget {
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
  final double customHeight;
  const OlukoNeumorphicPrimaryButton(
      {@required this.title,
      @required this.onPressed,
      // this.color,
      this.textColor = Colors.black,
      this.textAlign = TextAlign.center,
      this.icon,
      this.thinPadding = false,
      this.onlyIcon = false,
      this.isExpanded = true,
      this.customHeight = 50,
      this.isDisabled = false,
      this.useBorder = false,
      this.isPrimary = true})
      : super();

  @override
  _OlukoNeumorphicPrimaryButtonState createState() => _OlukoNeumorphicPrimaryButtonState();
}

class _OlukoNeumorphicPrimaryButtonState extends State<OlukoNeumorphicPrimaryButton> {
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
            child: primaryButton(),
          )
        : Container(height: widget.customHeight, child: primaryButton());
  }

  NeumorphicButton primaryButton() {
    return NeumorphicButton(
      onPressed: () => widget.onPressed != null ? widget.onPressed() : () {},
      padding: EdgeInsets.all(2),
      style: !widget.isDisabled
          ? OlukoNeumorphism.primaryButtonStyle(
              useBorder: widget.useBorder,
              buttonShape: NeumorphicShape.convex,
              boxShape: NeumorphicBoxShape.stadium(),
              ligthShadow: true,
              darkShadow: true)
          : OlukoNeumorphism.primaryButtonStyleDisable(
              useBorder: widget.useBorder,
              buttonShape: NeumorphicShape.convex,
              boxShape: NeumorphicBoxShape.stadium(),
              ligthShadow: true,
              darkShadow: true),
      child: Neumorphic(
        style: !widget.isDisabled
            ? OlukoNeumorphism.primaryButtonStyle(
                buttonShape: NeumorphicShape.flat, boxShape: NeumorphicBoxShape.stadium(), ligthShadow: true, darkShadow: true)
            : OlukoNeumorphism.primaryButtonStyleDisable(
                buttonShape: NeumorphicShape.convex, boxShape: NeumorphicBoxShape.stadium(), ligthShadow: true, darkShadow: true),
        child: Center(
          child: widget.onlyIcon ? widget.icon : _textLabel(),
        ),
      ),
    );
  }

  Widget _textLabel() {
    if (widget.thinPadding) {
      return Text(
        widget.title,
        textAlign: widget.textAlign,
        style: TextStyle(fontSize: 18, color: OlukoColors.white),
      );
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
