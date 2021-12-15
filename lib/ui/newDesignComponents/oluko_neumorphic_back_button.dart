import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:oluko_app/constants/theme.dart';

class OlukoNeumorphicBackButton extends StatefulWidget {
  const OlukoNeumorphicBackButton({
    @required this.onPressed,
  });

  final Function() onPressed;

  @override
  State<OlukoNeumorphicBackButton> createState() => _OlukoNeumorphicBackButtonState();
}

class _OlukoNeumorphicBackButtonState extends State<OlukoNeumorphicBackButton> {
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
          icon: Icon(Icons.arrow_back, size: 24, color: OlukoColors.grayColor),
          onPressed: () => {
                if (this.widget.onPressed == null) {Navigator.pop(context)} else {this.widget.onPressed()}
              }),
    );
  }
}
