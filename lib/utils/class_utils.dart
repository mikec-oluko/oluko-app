import 'package:flutter/material.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class ClassUtils {
  static String toClassProgress(int currentClass, int totalClasses, BuildContext context) {
    return "${OlukoLocalizations.get(context, 'class')} ${currentClass + 1} ${OlukoLocalizations.get(context, 'of')} $totalClasses";
  }
}
