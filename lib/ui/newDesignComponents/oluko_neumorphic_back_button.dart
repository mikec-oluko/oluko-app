import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:oluko_app/constants/theme.dart';

class OlukoNeumorphicCircleButton extends StatefulWidget {
  const OlukoNeumorphicCircleButton({@required this.onPressed, this.customIcon});

  final Function() onPressed;
  final Icon customIcon;

  @override
  State<OlukoNeumorphicCircleButton> createState() => _OlukoNeumorphicCircleButtonState();
}

class _OlukoNeumorphicCircleButtonState extends State<OlukoNeumorphicCircleButton> {
  @override
  Widget build(BuildContext context) {
    return Neumorphic(
      style: NeumorphicStyle(
          depth: 5,
          intensity: 0.6,
          color: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
          shape: NeumorphicShape.flat,
          lightSource: LightSource.topLeft,
          boxShape: NeumorphicBoxShape.circle(),
          shadowDarkColorEmboss: OlukoNeumorphismColors.olukoNeumorphicBackgroundLigth,
          shadowLightColorEmboss: OlukoColors.black,
          surfaceIntensity: 1,
          shadowLightColor: OlukoNeumorphismColors.olukoNeumorphicBackgroundLigth,
          shadowDarkColor: Colors.black),
      child: IconButton(
          padding: widget.customIcon != null ? EdgeInsets.zero : const EdgeInsets.only(left: 10),
          icon: widget.customIcon != null ? widget.customIcon : Icon(Icons.arrow_back_ios, size: 24, color: OlukoColors.grayColor),
          onPressed: () => {
                if (this.widget.onPressed == null) {Navigator.pop(context)} else {this.widget.onPressed()}
              }),
    );
  }
}
