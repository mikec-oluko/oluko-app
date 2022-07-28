import 'package:flutter/cupertino.dart';

class ScreenUtils {
  BuildContext context;
  ScreenUtils(this.context);

  static double height(BuildContext context) => MediaQuery.of(context).size.height;
  static double width(BuildContext context) => MediaQuery.of(context).size.width;
  static bool smallScreen(BuildContext context) => MediaQuery.of(context).size.height < 700;
  static bool mediumScreen(BuildContext context) => MediaQuery.of(context).size.height >= 700 && MediaQuery.of(context).size.height < 850;
  static bool bigScreen(BuildContext context) => MediaQuery.of(context).size.height >= 850;
  static bool modifiedFont(BuildContext context) => MediaQuery.of(context).textScaleFactor > 1;
}
