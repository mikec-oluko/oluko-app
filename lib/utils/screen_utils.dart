import 'package:flutter/cupertino.dart';
import 'package:oluko_app/constants/theme.dart';

class ScreenUtils {
  BuildContext context;
  ScreenUtils(this.context);

  static double height(BuildContext context) => MediaQuery.of(context).size.height;
  static double width(BuildContext context) => MediaQuery.of(context).size.width;
  static bool smallScreen(BuildContext context) => MediaQuery.of(context).size.height < 700;
  static bool mediumScreen(BuildContext context) => MediaQuery.of(context).size.height >= 700 && MediaQuery.of(context).size.height < 850;
  static bool bigScreen(BuildContext context) => MediaQuery.of(context).size.height >= 850;
  static bool modifiedFont(BuildContext context) => MediaQuery.of(context).textScaleFactor > 1;

  static double getAdaptiveHeight(BuildContext context) {
    return OlukoNeumorphism.isNeumorphismDesign
        ? ScreenUtils.height(context) < 700
            ? ScreenUtils.height(context) / 2.5
            : ScreenUtils.height(context) / 2.8
        : ScreenUtils.height(context) / 5;
  }
}
