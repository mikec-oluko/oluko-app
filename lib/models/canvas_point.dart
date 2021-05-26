import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:oluko_app/ui/draw.dart';

class CanvasPoint {
  DrawingPoints point;
  num timeStamp;

  CanvasPoint({this.point, this.timeStamp});

  Map<String, dynamic> toJson() {
    return {
      "x": this.point.points.dx,
      "y": this.point.points.dy,
      "timeStamp": this.timeStamp,
    };
  }

  //Convert stored json into CanvasPoint
  factory CanvasPoint.fromJson(Map<String, dynamic> json) {
    return CanvasPoint(
      point: json['x'] == null
          ? null
          : DrawingPoints(
              points: Offset(json['x'], json['y']),
              paint: Paint()
                ..strokeWidth = 3.0
                ..isAntiAlias = true
                ..strokeCap = StrokeCap.butt
                ..color = Colors.red),
      timeStamp: json['timeStamp'],
    );
  }
}
