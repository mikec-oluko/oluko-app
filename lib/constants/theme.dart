import 'dart:math';
import 'dart:ui' show Color;

import 'package:flutter/material.dart';

class OlukoColors {
  static const Color black = Color(0xFF000000);

  static const Color black87 = Colors.black87;

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

  static const Color divider = Colors.white12;

  static const Color searchBarText = Colors.white;

  static const Color searchSuggestionsText = Colors.white;

  static const Color searchSuggestionsAlreadyWrittenText = Color.fromRGBO(170, 176, 144, 1.0);

  static const Color appBarIcon = Colors.white;

  static const Color grayColor = Color.fromRGBO(149, 149, 149, 1.0);

  static const Color listGrayColor = Color.fromRGBO(57, 57, 57, 1);

  static const Color grayColorFadeTop = Color.fromRGBO(53, 58, 64, 1.0);

  static const Color grayColorFadeBottom = Color.fromRGBO(22, 23, 27, 1);

  static const Color challengesGreyBackground = Color(0xFF303030);

  static const Color coral = Color.fromRGBO(247, 177, 171, 1);

  static const Color skyblue = Color.fromRGBO(171, 247, 233, 1);

  static const Color purple = Color.fromRGBO(171, 147, 233, 1);

  static const Color orange = Color.fromRGBO(251, 147, 133, 1);

  static const Color challengeLockedFilterColor = Color.fromRGBO(218, 5, 5, 0.2);

  static const Color grayColorSemiTransparent = Color.fromRGBO(148, 148, 148, 0.6);

  static const Color blackColorSemiTransparent = Color.fromRGBO(24, 24, 24, 0.6);

  static const Color taskCardBackgroundDisabled = Color.fromRGBO(30, 30, 30, 0.8);

  static const Color disabled = Color.fromRGBO(30, 30, 30, 0.8);

  static const Color coachTabIndicatorColor = Color.fromRGBO(247, 177, 171, 1);

  static Color randomColor() {
    var list = [grayColorSemiTransparent, skyblue, coral, searchSuggestionsAlreadyWrittenText, inputError, purple, orange];
    final _random = new Random();
    return list[_random.nextInt(list.length)];
  }

  static Color userColor(String firstName, String lastName) {
    var list = [grayColorSemiTransparent, skyblue, coral, searchSuggestionsAlreadyWrittenText, inputError, purple, orange];
    if (firstName == null) {
      var rndm = Random();
      var position = rndm.nextInt(list.length);
      return list[position];
    }
    int index = firstName.codeUnitAt(0) + lastName.codeUnitAt(0);

    return list[index % list.length];
  }
}

class OlukoFonts {
  static const double olukoTitleFontSize = 28.0;
  static const double olukoSubtitleFontSize = 25.0;
  static const double olukoBigFontSize = 18.0;
  static const double olukoSuperBigFontSize = 21.0;
  static const double olukoMediumFontSize = 14.0;
  static const double olukoSmallFontSize = 11.0;
  static const double olukoBiggestFontSize = 40.0;

  static TextStyle olukoMediumFont({FontWeight custoFontWeight, Color customColor, TextDecoration decoration}) {
    return TextStyle(
        fontSize: olukoMediumFontSize,
        fontWeight: custoFontWeight != null ? custoFontWeight : FontWeight.w500,
        color: customColor != null ? customColor : OlukoColors.white,
        decoration: decoration);
  }

  static TextStyle olukoTitleFont({FontWeight custoFontWeight, Color customColor}) {
    return TextStyle(
        fontSize: olukoTitleFontSize,
        fontWeight: custoFontWeight != null ? custoFontWeight : FontWeight.w500,
        color: customColor != null ? customColor : OlukoColors.white);
  }

  static TextStyle olukoSubtitleFont({FontWeight custoFontWeight, Color customColor}) {
    return TextStyle(
        fontSize: olukoSubtitleFontSize,
        fontWeight: custoFontWeight != null ? custoFontWeight : FontWeight.w500,
        color: customColor != null ? customColor : OlukoColors.white);
  }

  static TextStyle olukoBigFont({FontWeight custoFontWeight, Color customColor}) {
    return TextStyle(
        fontSize: olukoBigFontSize,
        fontWeight: custoFontWeight != null ? custoFontWeight : FontWeight.w500,
        color: customColor != null ? customColor : OlukoColors.white);
  }

  static TextStyle olukoSuperBigFont({FontWeight custoFontWeight, Color customColor}) {
    return TextStyle(
        fontSize: olukoSuperBigFontSize,
        fontWeight: custoFontWeight != null ? custoFontWeight : FontWeight.w500,
        color: customColor != null ? customColor : OlukoColors.white);
  }

  static TextStyle olukoSmallFont({FontWeight custoFontWeight, Color customColor}) {
    return TextStyle(
        fontSize: olukoSmallFontSize,
        fontWeight: custoFontWeight != null ? custoFontWeight : FontWeight.w500,
        color: customColor != null ? customColor : OlukoColors.white);
  }

  static TextStyle olukoBiggestFont({FontWeight custoFontWeight, Color customColor}) {
    return TextStyle(
        fontSize: olukoBiggestFontSize,
        fontWeight: custoFontWeight != null ? custoFontWeight : FontWeight.w500,
        color: customColor != null ? customColor : OlukoColors.white);
  }
}
