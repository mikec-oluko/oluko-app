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
    return Neumorphic(
      style: const NeumorphicStyle(
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
          shadowDarkColor: OlukoColors.black),
      child: widget.defaultAspect
          ? ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: GestureDetector(
                onTap: () {
                  if (widget.onPressed == null) {
                    Navigator.pop(context);
                  } else {
                    widget.onPressed();
                  }
                },
                child: Container(
                    width: 40,
                    height: 40,
                    child: Image.asset(
                      'assets/courses/left_back_arrow.png',
                      scale: 3.5,
                    )),
              ))
          : IconButton(
              padding: widget.customIcon != null ? EdgeInsets.zero : const EdgeInsets.only(left: 10),
              icon: widget.customIcon ?? const Icon(Icons.arrow_back_ios, size: 24, color: OlukoColors.grayColor),
              onPressed: () => {
                    if (widget.onPressed == null) {Navigator.pop(context)} else {widget.onPressed()}
                  }),
    );
  }
}
