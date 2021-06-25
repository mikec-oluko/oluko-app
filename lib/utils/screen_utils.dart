import 'package:flutter/cupertino.dart';

class ScreenUtils {
  BuildContext context;
  ScreenUtils(this.context);

  static double height(context) => MediaQuery.of(context).size.height;
  static double width(context) => MediaQuery.of(context).size.width;
}
