import 'package:flutter/material.dart';
import 'package:mvt_fitness/ui/components/oluko_circular_progress_indicator.dart';

class ImageUtils {
  static Widget frameBuilder(
      context, Widget child, int frame, bool wasSynchronouslyLoaded,
      {double height = 120, double width}) {
    return Stack(
      alignment: Alignment.center,
      children: [
        frame == null
            ? Container(height: height, child: OlukoCircularProgressIndicator())
            : SizedBox(),
        AnimatedOpacity(
            opacity: frame == null ? 0 : 1,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeOut,
            child: child),
      ],
    );
  }
}
