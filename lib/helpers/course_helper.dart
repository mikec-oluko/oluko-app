import 'package:flutter/cupertino.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class CourseHelper {
  static double getAdaptiveSizeForTitle(int textLength, BuildContext context) {
    var width = ScreenUtils.width(context);
    int charactersPerLine = ((width * 25) / 355).toInt();
    if (textLength < charactersPerLine) {
      return ScreenUtils.height(context) * 0.08 * MediaQuery.of(context).textScaleFactor;
    } else {
      return ScreenUtils.height(context) * (0.08 + ((textLength ~/ charactersPerLine) - 1) * 0.08) * MediaQuery.of(context).textScaleFactor;
    }
    //0.08 is the minimun size for one line of title
  }
}
