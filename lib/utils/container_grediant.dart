import 'package:flutter/material.dart';
import 'package:oluko_app/constants/Theme.dart';

class ContainerGradient {
  static BoxDecoration getContainerGradientDecoration() {
    return  BoxDecoration(
            gradient: LinearGradient(colors: [
              OlukoColors.grayColorFadeTop,
              OlukoColors.grayColorFadeBottom
            ], stops: [
              0.0,
              1
            ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
            color: OlukoColors.secondary,
            borderRadius: BorderRadius.all(Radius.circular(5)));
  }
}