import 'package:flutter/cupertino.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class CourseHelper {
  static double getAdaptiveSizeForTitle(int textLength, int charactersPerLine, BuildContext context) {
    if (textLength < charactersPerLine) {
      return ScreenUtils.height(context) * 0.08;
    } else {
      return ScreenUtils.height(context) * (0.08 + ((textLength ~/ charactersPerLine) - 1) * 0.08);
    }
    //0.08 is the minimun size for one line of title 
  }
}
