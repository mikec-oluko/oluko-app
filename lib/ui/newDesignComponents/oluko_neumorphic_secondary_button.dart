import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:oluko_app/constants/theme.dart';

class OlukoNeumorphicSecondaryButton extends StatefulWidget {
  final Function() onPressed;
  final String title;
  final Color textColor;
  final TextAlign textAlign;
  final Widget icon;
  final NeumorphicShape buttonShape;
  final bool thinPadding;
  final bool onlyIcon;
  final bool isDisabled;
  final bool isPrimary;
  final bool useBorder;
  final bool isExpanded;
  final bool lighterButton;
  final double customHeight;
  const OlukoNeumorphicSecondaryButton(
      {@required this.title,
      @required this.onPressed,
      this.thinPadding = false,
      // this.color,
      this.textColor = OlukoColors.grayColor,
      this.textAlign = TextAlign.center,
      this.icon,
      this.buttonShape,
      this.isDisabled = false,
      this.onlyIcon = false,
      this.isExpanded = true,
      this.customHeight = 50,
      this.useBorder = false,
      this.isPrimary = true,
      this.lighterButton = false})
      : super();

  @override
  _OlukoNeumorphicButtonState createState() => _OlukoNeumorphicButtonState();
}

class _OlukoNeumorphicButtonState extends State<OlukoNeumorphicSecondaryButton> {
  Color buttonColor = OlukoColors.primary;

  @override
  Widget build(BuildContext context) {
    return widget.isExpanded
        ? Expanded(
            child: widget.lighterButton ? lighterSecondaryButton() : secondaryButton(),
          )
        : Center(child: Container(height: widget.customHeight, child: widget.lighterButton ? lighterSecondaryButton() : secondaryButton()));
  }

  NeumorphicButton secondaryButton() {
    return NeumorphicButton(
      onPressed: () {
        widget.onPressed != null ? widget.onPressed() : () {};
      },
      padding: const EdgeInsets.all(2),
      style: OlukoNeumorphism.secondaryButtonStyle(
          useBorder: widget.useBorder, buttonShape: widget.buttonShape, boxShape: NeumorphicBoxShape.stadium(), lightShadow: true, darkShadow: true),
      child: Neumorphic(
        style: OlukoNeumorphism.secondaryButtonStyle(
            buttonShape: widget.buttonShape, boxShape: const NeumorphicBoxShape.stadium(), lightShadow: true, darkShadow: true),
        child: Center(
          child: widget.onlyIcon ? widget.icon : _textLabel(),
        ),
      ),
    );
  }

  NeumorphicButton lighterSecondaryButton() {
    return NeumorphicButton(
      onPressed: () {
        widget.onPressed != null ? widget.onPressed() : () {};
      },
      padding: EdgeInsets.all(2),
      style: OlukoNeumorphism.getNeumorphicStyleForCircleElementNegativeDepth().copyWith(
          lightSource: LightSource.bottom,
          intensity: 1,
          boxShape: NeumorphicBoxShape.stadium(),
          border: NeumorphicBorder(width: 3, color: OlukoNeumorphismColors.olukoNeumorphicBackgroundDarker)),
      child: Neumorphic(
        style: OlukoNeumorphism.secondaryButtonStyle(
          buttonShape: widget.buttonShape,
          boxShape: NeumorphicBoxShape.stadium(),
          lightShadow: true,
          darkShadow: true,
        ).copyWith(color: OlukoNeumorphismColors.olukoNeumorphicBackgroundLigth),
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
        style: OlukoFonts.olukoBigFont(
          customColor: widget.textColor,
        ),
      );
    } else {
      return Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            widget.title,
            textAlign: widget.textAlign,
            style: OlukoFonts.olukoBigFont(customColor: widget.textColor),
          ));
    }
  }
}
