import 'dart:ui' show Color;

import 'package:flutter/material.dart';

class OlukoColors {
  static const Color black = Color(0xFF000000);

  static const Color white = Color(0xFFFFFFFF);

  static const Color initial = Color.fromRGBO(23, 43, 77, 1.0);

  static const Color primary = Color.fromRGBO(170, 176, 144, 1.0);

  static const Color secondary = Color.fromRGBO(228, 155, 149, 1.0);

  static const Color label = Color.fromRGBO(254, 36, 114, 1.0);

  static const Color info = Color.fromRGBO(17, 205, 239, 1.0);

  static const Color error = Color.fromRGBO(245, 54, 92, 1.0);

  static const Color success = Color.fromRGBO(45, 206, 137, 1.0);

  static const Color warning = Color.fromRGBO(251, 99, 64, 1.0);

  static const Color header = Color.fromRGBO(82, 95, 127, 1.0);

  static const Color bgColorScreen = Color.fromRGBO(248, 249, 254, 1.0);

  static const Color border = Color.fromRGBO(202, 209, 215, 1.0);

  static const Color inputSuccess = Color.fromRGBO(123, 222, 177, 1.0);

  static const Color inputError = Color.fromRGBO(252, 179, 164, 1.0);

  static const Color muted = Color.fromRGBO(136, 152, 170, 1.0);

  static const Color text = Color.fromRGBO(50, 50, 93, 1.0);

  static const Color taskCardBackground = Color.fromRGBO(40, 40, 40, 1.0);

  static const Color grayColor = Color.fromRGBO(149, 149, 149, 1.0);

  static const Color listGrayColor = Color.fromRGBO(57, 57, 57, 1.0);

  static const Color challengesGreyBackground = Color(0xFF303030);

  static const Color grayColorSemiTransparent =
      Color.fromRGBO(148, 148, 148, 0.6);
}

class OlukoFonts {
  static const double olukoTitleFontSize = 30.0;
  static const double olukoBigFontSize = 18.0;
  static const double olukoMediumFontSize = 14.0;
  static const double olukoSmallFontSize = 11.0;

  static TextStyle olukoMediumFont(
      {FontWeight custoFontWeight, Color customColor}) {
    return TextStyle(
        fontSize: olukoMediumFontSize,
        fontWeight: custoFontWeight != null ? custoFontWeight : FontWeight.w500,
        color: customColor != null ? customColor : OlukoColors.white);
  }

  static TextStyle olukoTitleFont(
      {FontWeight custoFontWeight, Color customColor}) {
    return TextStyle(
        fontSize: olukoTitleFontSize,
        fontWeight: custoFontWeight != null ? custoFontWeight : FontWeight.w500,
        color: customColor != null ? customColor : OlukoColors.white);
  }

  static TextStyle olukoBigFont(
      {FontWeight custoFontWeight, Color customColor}) {
    return TextStyle(
        fontSize: olukoBigFontSize,
        fontWeight: custoFontWeight != null ? custoFontWeight : FontWeight.w500,
        color: customColor != null ? customColor : OlukoColors.white);
  }

  static TextStyle olukoSmallFont(
      {FontWeight custoFontWeight, Color customColor}) {
    return TextStyle(
        fontSize: olukoSmallFontSize,
        fontWeight: custoFontWeight != null ? custoFontWeight : FontWeight.w500,
        color: customColor != null ? customColor : OlukoColors.white);
  }
}
