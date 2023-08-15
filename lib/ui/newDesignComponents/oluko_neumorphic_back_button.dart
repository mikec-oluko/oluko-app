import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:oluko_app/constants/theme.dart';

class OlukoNeumorphicCircleButton extends StatefulWidget {
  const OlukoNeumorphicCircleButton({@required this.onPressed, this.customIcon, this.defaultAspect = false});

  final Function() onPressed;
  final Icon customIcon;
  final bool defaultAspect;
  @override
  State<OlukoNeumorphicCircleButton> createState() => _OlukoNeumorphicCircleButtonState();
}

class _OlukoNeumorphicCircleButtonState extends State<OlukoNeumorphicCircleButton> {
  @override
  Widget build(BuildContext context) {
    return NeumorphicButton(
        style: const NeumorphicStyle(
            depth: 5,
            intensity: 0.6,
            color: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
            boxShape: NeumorphicBoxShape.circle(),
            shadowDarkColorEmboss: OlukoNeumorphismColors.olukoNeumorphicBackgroundLight,
            shadowLightColorEmboss: OlukoColors.black,
            surfaceIntensity: 1,
            shadowLightColor: OlukoNeumorphismColors.olukoNeumorphicBackgroundLight,
            shadowDarkColor: OlukoColors.black),
        child: Container(
          width: 35,
          height: 35,
          child: widget.customIcon ??
              Image.asset(
                'assets/courses/left_back_arrow.png',
                scale: 3.5,
              ),
        ),
        onPressed: () {
          if (widget.onPressed == null) {
            Navigator.pop(context);
          } else {
            widget.onPressed();
          }
        });
  }
}
