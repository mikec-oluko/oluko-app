import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';

class UserInformationBackground {
  static BoxDecoration getContainerGradientDecoration({bool customBorder = false, bool isNeumorphic = false, bool useGradient = false}) {
    return isNeumorphic
        ? BoxDecoration(
            gradient: useGradient ? OlukoNeumorphism.OlukoNeumorphicGradientBlueAccent() : null,
            color: OlukoNeumorphismColors.olukoNeumorphicGreyBackgroundFlat,
            borderRadius: customBorder
                ? const BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15))
                : BorderRadius.all(Radius.circular(10.0)))
        : BoxDecoration(
            gradient: const LinearGradient(
                colors: [OlukoColors.grayColorFadeTop, OlukoColors.grayColorFadeBottom],
                stops: [0.0, 1],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter),
            color: OlukoColors.secondary,
            borderRadius: customBorder
                ? const BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5))
                : const BorderRadius.all(Radius.circular(5)));
  }
}
