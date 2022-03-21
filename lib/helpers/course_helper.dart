import 'package:flutter/cupertino.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class CourseHelper {
  static double getAdaptiveSizeForTitle(int textLength, BuildContext context) {
    var width = ScreenUtils.width(context);
    int charactersPerLine = ((width * 25) / 375).toInt();
    if (textLength < charactersPerLine) {
      return ScreenUtils.height(context) * 0.09 * MediaQuery.of(context).textScaleFactor;
    } else {
      return ScreenUtils.height(context) *
          (0.09 + ((textLength ~/ charactersPerLine) - 0.5) * 0.09) *
          MediaQuery.of(context).textScaleFactor;
    }
    //0.08 is the minimun size for one line of title
    //25 are the characters that fit in 355 px
  }
}
