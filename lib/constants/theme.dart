import 'dart:math';
import 'dart:ui' show Color;
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

class OlukoNeumorphism {
  static const bool isNeumorphismDesign = true;
  static const Radius radiusValue = Radius.circular(15.0);
  static const String mvtLogo = 'assets/home/mvt.png';

  static NeumorphicStyle primaryButtonStyleDisable(
      {bool useBorder = false, bool ligthShadow = true, bool darkShadow = true, num depth = 3, NeumorphicShape buttonShape, NeumorphicBoxShape boxShape}) {
    return NeumorphicStyle(
        border: useBorder ? const NeumorphicBorder(width: 1.5, color: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark) : const NeumorphicBorder.none(),
        depth: 5,
        intensity: 0.5,
        color: OlukoNeumorphismColors.initialGradientColorPrimary.withOpacity(0.25),
        shape: buttonShape,
        lightSource: LightSource.top,
        boxShape: boxShape,
        shadowDarkColorEmboss: OlukoNeumorphismColors.finalGradientColorPrimary,
        shadowLightColorEmboss: OlukoColors.black,
        surfaceIntensity: 1,
        shadowLightColor: ligthShadow ? Colors.white60 : Colors.transparent,
        shadowDarkColor: darkShadow ? Colors.black : Colors.transparent);
  }

  static NeumorphicStyle primaryButtonStyle(
      {bool useBorder = false,
      bool ligthShadow = true,
      bool darkShadow = true,
      num depth = 3,
      NeumorphicShape buttonShape,
      NeumorphicBoxShape boxShape,
      Color customColor}) {
    return NeumorphicStyle(
        border: useBorder ? const NeumorphicBorder(width: 1.5, color: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark) : const NeumorphicBorder.none(),
        depth: 5,
        intensity: 0.5,
        color: customColor ?? OlukoNeumorphismColors.initialGradientColorPrimary,
        shape: buttonShape,
        lightSource: LightSource.top,
        boxShape: boxShape,
        shadowDarkColorEmboss: OlukoNeumorphismColors.finalGradientColorPrimary,
        shadowLightColorEmboss: OlukoColors.black,
        surfaceIntensity: 1,
        shadowLightColor: ligthShadow ? Colors.white60 : Colors.transparent,
        shadowDarkColor: darkShadow ? Colors.black : Colors.transparent);
  }

  static NeumorphicStyle whiteButtonStyle(
      {bool useBorder = false,
      bool ligthShadow = true,
      bool isDisabled = false,
      bool darkShadow = true,
      num depth = 3,
      NeumorphicShape buttonShape,
      NeumorphicBoxShape boxShape}) {
    return NeumorphicStyle(
        border: useBorder
            ? NeumorphicBorder(width: 1.5, color: isDisabled ? OlukoColors.grayColor.withOpacity(0.2) : OlukoColors.primary)
            : const NeumorphicBorder.none(),
        depth: 5,
        intensity: 0.5,
        color: isDisabled ? OlukoColors.grayColor.withOpacity(0.15) : OlukoColors.white,
        shape: isDisabled ? NeumorphicShape.concave : buttonShape,
        lightSource: LightSource.top,
        boxShape: boxShape,
        shadowDarkColorEmboss: isDisabled ? OlukoColors.white : OlukoNeumorphismColors.finalGradientColorPrimary,
        shadowLightColorEmboss: isDisabled ? OlukoColors.white : OlukoColors.black,
        surfaceIntensity: isDisabled ? 0.25 : 1,
        shadowLightColor: ligthShadow ? Colors.white60 : Colors.transparent,
        shadowDarkColor: darkShadow ? Colors.black : Colors.transparent);
  }

  static NeumorphicStyle secondaryButtonStyle(
      {bool useBorder = false, bool lightShadow = true, bool darkShadow = true, num depth = 3, NeumorphicShape buttonShape, NeumorphicBoxShape boxShape}) {
    return NeumorphicStyle(
        border: useBorder ? const NeumorphicBorder(width: 1.5, color: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark) : const NeumorphicBorder.none(),
        depth: 5,
        intensity: 0.5,
        color: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
        shape: buttonShape,
        lightSource: LightSource.top,
        boxShape: boxShape,
        shadowDarkColorEmboss: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
        shadowLightColorEmboss: OlukoColors.black,
        surfaceIntensity: 0.5,
        shadowLightColor: lightShadow ? Colors.white60 : Colors.transparent,
        shadowDarkColor: darkShadow ? Colors.black : Colors.transparent);
  }

  static NeumorphicStyle getNeumorphicStyleForCircleElement() {
    return const NeumorphicStyle(
        border: NeumorphicBorder(width: 1.5, color: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark),
        depth: 3,
        intensity: 0.5,
        color: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
        shape: NeumorphicShape.flat,
        lightSource: LightSource.topLeft,
        boxShape: NeumorphicBoxShape.circle(),
        shadowDarkColorEmboss: OlukoNeumorphismColors.initialGradientColorPrimary,
        shadowLightColorEmboss: OlukoColors.black,
        surfaceIntensity: 1,
        shadowLightColor: OlukoColors.grayColor,
        shadowDarkColor: Colors.black);
  }

  static NeumorphicStyle getNeumorphicStyleForCirclePrimaryColor() {
    return getNeumorphicStyleForCircleElement().copyWith(
      shape: NeumorphicShape.convex,
      color: OlukoColors.primary,
      surfaceIntensity: 0.5,
    );
  }

  static NeumorphicStyle getNeumorphicStyleForInnerCircleWatch() {
    return const NeumorphicStyle(
        depth: -12,
        intensity: 0.95,
        color: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
        shape: NeumorphicShape.concave,
        boxShape: NeumorphicBoxShape.circle(),
        shadowDarkColorEmboss: OlukoNeumorphismColors.olukoNeumorphicSearchBarFirstColor,
        shadowLightColorEmboss: OlukoNeumorphismColors.olukoNeumorphicSearchBarSecondColor,
        surfaceIntensity: 1,
        shadowLightColor: OlukoNeumorphismColors.olukoNeumorphicBackgroundLigth,
        shadowDarkColor: OlukoNeumorphismColors.olukoNeumorphicSearchBarSecondColor,
        oppositeShadowLightSource: true);
  }

  static NeumorphicStyle getNeumorphicStyleForCircleElementNegativeDepth() {
    return const NeumorphicStyle(
        border: NeumorphicBorder(width: 3, color: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark),
        depth: -2,
        intensity: 0.5,
        color: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
        lightSource: LightSource.topLeft,
        boxShape: NeumorphicBoxShape.circle(),
        surfaceIntensity: 1,
        shadowLightColor: OlukoColors.grayColor,
        shadowDarkColor: Colors.black);
  }

  static NeumorphicStyle getNeumorphicStyleForCircleWatchWithShadows() {
    return NeumorphicStyle(
        depth: 15,
        intensity: 1,
        color: OlukoNeumorphismColors.olukoNeumorphicBackgroundLigth,
        boxShape: const NeumorphicBoxShape.circle(),
        shadowDarkColorEmboss: OlukoNeumorphismColors.olukoNeumorphicBackgroundLigth,
        shadowLightColorEmboss: OlukoNeumorphismColors.olukoNeumorphicSearchBarSecondColor.withOpacity(0.5),
        surfaceIntensity: 0.4,
        shadowLightColor: OlukoNeumorphismColors.olukoNeumorphicBackgroundLigth,
        shadowDarkColor: OlukoNeumorphismColors.olukoNeumorphicSearchBarSecondColor.withOpacity(0.9));
  }

  static NeumorphicStyle getNeumorphicStyleForCardElement() {
    return NeumorphicStyle(
        border: NeumorphicBorder(width: 1.5, color: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark),
        depth: 6,
        intensity: 0.8,
        color: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
        shape: NeumorphicShape.flat,
        lightSource: LightSource.topLeft,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.all(Radius.circular(5))),
        shadowDarkColorEmboss: OlukoNeumorphismColors.olukoNeumorphicBackgroundLigth,
        shadowLightColorEmboss: OlukoColors.black,
        surfaceIntensity: 1,
        shadowLightColor: OlukoNeumorphismColors.olukoNeumorphicBackgroundLigth,
        shadowDarkColor: Colors.black);
  }

  static NeumorphicStyle getNeumorphicStyleForStackCardElement() {
    return NeumorphicStyle(
        border: NeumorphicBorder.none(),
        depth: 6,
        intensity: 0.8,
        color: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
        shape: NeumorphicShape.flat,
        lightSource: LightSource.topLeft,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.all(Radius.circular(5))),
        shadowDarkColorEmboss: OlukoNeumorphismColors.olukoNeumorphicBackgroundLigth,
        shadowLightColorEmboss: OlukoColors.black,
        surfaceIntensity: 1,
        shadowLightColor: OlukoNeumorphismColors.finalGradientColorDark,
        shadowDarkColor: Colors.black);
  }

  static NeumorphicStyle getNeumorphicStyleForCardClasses(bool isStarted) {
    return NeumorphicStyle(
        border: isStarted ? NeumorphicBorder.none() : NeumorphicBorder(width: 15, color: Colors.transparent),
        depth: -10,
        intensity: 1,
        color: Colors.transparent,
        shape: NeumorphicShape.flat,
        lightSource: LightSource.bottomRight,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.all(Radius.circular(22))),
        shadowDarkColorEmboss: OlukoColors.grayColor.withOpacity(0.5),
        shadowLightColorEmboss: OlukoNeumorphismColors.olukoNeumorphicBackgroundDarker,
        surfaceIntensity: 1,
        shadowDarkColor: OlukoNeumorphismColors.olukoNeumorphicBackgroundDarker);
  }

  static LinearGradient olukoNeumorphicGradientPrimary() {
    return const LinearGradient(
        colors: [OlukoNeumorphismColors.initialGradientColorPrimary, OlukoNeumorphismColors.finalGradientColorPrimary],
        stops: [0.0, 1],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter);
  }

  static LinearGradient olukoNeumorphicGradientDark() {
    return const LinearGradient(
        colors: [OlukoNeumorphismColors.initialGradientColorDark, OlukoNeumorphismColors.finalGradientColorDark],
        stops: [0.0, 1],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter);
  }

  static LinearGradient olukoNeumorphicGradientBlueAccent() {
    return const LinearGradient(colors: [
      OlukoNeumorphismColors.olukoNeumorphicSearchBarSecondColor,
      OlukoNeumorphismColors.olukoNeumorphicSearchBarFirstColor,
    ], stops: [
      0.0,
      1
    ], begin: Alignment.topCenter, end: Alignment.bottomCenter);
  }
}

class OlukoNeumorphismColors {
  static const Color olukoNeumorphicBackgroundLigth = Color.fromRGBO(43, 47, 52, 1);
  static const Color olukoNeumorphicBackgroundDark = Color.fromRGBO(26, 30, 33, 1);
  static const Color olukoNeumorphicBackgroundDarker = Color.fromRGBO(32, 36, 39, 1);
  static const Color initialGradientColorPrimary = Color.fromRGBO(192, 198, 155, 1);
  static const Color finalGradientColorPrimary = Color.fromRGBO(192, 131, 98, 1);
  static const Color initialGradientColorDark = Color.fromRGBO(47, 53, 58, 1);
  static const Color finalGradientColorDark = Color.fromRGBO(28, 31, 34, 1);
  static const Color olukoNeumorphicGreyBackgroundFlat = Color.fromRGBO(42, 45, 47, 1);
  static const Color olukoNeumorphicSearchBarFirstColor = Color.fromRGBO(29, 35, 40, 1);
  static const Color olukoNeumorphicSearchBarSecondColor = Color.fromRGBO(19, 19, 20, 1);
  static const Color olukoNeumorphicBlueBackgroundColor = Color(0XFF1976D2);
  static const List<Color> homeGradientColorList = [Color(0xFF3e3737), Color(0xFFbfbaba), Color(0xFF3e3737)];
  static const Color olukoNeumorphicGreenWatchColor = Color.fromRGBO(51, 188, 132, 1);
  static const Color appBackgroundColor = OlukoNeumorphism.isNeumorphismDesign ? OlukoNeumorphismColors.olukoNeumorphicBackgroundDark : Colors.black;
}

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

  static const Color yellow = Color.fromRGBO(254, 192, 0, 1);

  static const Color challengeLockedFilterColor = Color.fromRGBO(218, 5, 5, 0.2);

  static const Color grayColorSemiTransparent = Color.fromRGBO(148, 148, 148, 0.6);

  static const Color blackColorSemiTransparent = Color.fromRGBO(24, 24, 24, 0.6);

  static const Color taskCardBackgroundDisabled = Color.fromRGBO(30, 30, 30, 0.8);

  static const Color disabled = Color.fromRGBO(30, 30, 30, 0.8);

  static const Color lightOrange = Color.fromRGBO(254, 159, 31, 1);

  static const Color lightSkyblue = Color.fromRGBO(171, 247, 233, 1);

    static const Color strongYellow = Color.fromRGBO(254, 192, 0, 1);

  static const Color coachTabIndicatorColor = Color.fromRGBO(247, 177, 171, 1);

  static const Color statisticsChartColor = Color.fromRGBO(254, 159, 31, 1);

  static const Color subscription = Color.fromRGBO(254, 159, 31, 1);

  static const Color subscriptionTabsColor = Color.fromRGBO(228, 229, 230, 1);

  static Color randomColor() {
    var list = [grayColorSemiTransparent, skyblue, coral, searchSuggestionsAlreadyWrittenText, inputError, purple, orange];
    final _random = new Random();
    return list[_random.nextInt(list.length)];
  }

  static Color userColor(String firstName, String lastName) {
    var list = [grayColorSemiTransparent, skyblue, coral, inputError, purple, orange];
    if (firstName == null || firstName.isEmpty || lastName == null || lastName.isEmpty) {
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

  static TextStyle olukoMediumFont({FontWeight customFontWeight, Color customColor, TextDecoration decoration}) {
    return TextStyle(
        fontFamily: 'Roboto',
        fontSize: olukoMediumFontSize,
        fontWeight: customFontWeight != null ? customFontWeight : FontWeight.w500,
        color: customColor != null ? customColor : OlukoColors.white,
        decoration: decoration);
  }

  static TextStyle olukoTitleFont({FontWeight customFontWeight, Color customColor}) {
    return TextStyle(
        fontFamily: 'Roboto',
        fontSize: olukoTitleFontSize,
        fontWeight: customFontWeight != null ? customFontWeight : FontWeight.w500,
        color: customColor != null ? customColor : OlukoColors.white);
  }

  static TextStyle olukoSubtitleFont({FontWeight customFontWeight, Color customColor}) {
    return TextStyle(
        fontFamily: 'Roboto',
        fontSize: olukoSubtitleFontSize,
        fontWeight: customFontWeight != null ? customFontWeight : FontWeight.w500,
        color: customColor != null ? customColor : OlukoColors.white);
  }

  static TextStyle olukoBigFont({FontWeight customFontWeight, Color customColor}) {
    return TextStyle(
        fontFamily: 'Roboto',
        fontSize: olukoBigFontSize,
        fontWeight: customFontWeight != null ? customFontWeight : FontWeight.w500,
        color: customColor != null ? customColor : OlukoColors.white);
  }

  static TextStyle olukoSuperBigFont({FontWeight customFontWeight, Color customColor}) {
    return TextStyle(
        fontFamily: 'Roboto',
        fontSize: olukoSuperBigFontSize,
        fontWeight: customFontWeight != null ? customFontWeight : FontWeight.w500,
        color: customColor != null ? customColor : OlukoColors.white);
  }

  static TextStyle olukoSmallFont({FontWeight customFontWeight, Color customColor}) {
    return TextStyle(
        fontFamily: 'Roboto',
        fontSize: olukoSmallFontSize,
        fontWeight: customFontWeight != null ? customFontWeight : FontWeight.w500,
        color: customColor != null ? customColor : OlukoColors.white);
  }

  static TextStyle olukoBiggestFont({FontWeight customFontWeight, Color customColor}) {
    return TextStyle(
        fontFamily: 'Roboto',
        fontSize: olukoBiggestFontSize,
        fontWeight: customFontWeight != null ? customFontWeight : FontWeight.w500,
        color: customColor != null ? customColor : OlukoColors.white);
  }
}
