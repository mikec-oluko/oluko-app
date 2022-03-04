import 'package:flutter/cupertino.dart';

class ScreenUtils {
  BuildContext context;
  ScreenUtils(this.context);

  static double height(BuildContext context) => MediaQuery.of(context).size.height;
  static double width(BuildContext context) => MediaQuery.of(context).size.width;
  static bool smallScreen(BuildContext context) => MediaQuery.of(context).size.height < 700;
}
