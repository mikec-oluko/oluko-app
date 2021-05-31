import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:oluko_app/ui/draw.dart';

class DrawPoint {
  DrawingPoints point;
  num timeStamp;

  DrawPoint({this.point, this.timeStamp});

  Map<String, dynamic> toJson() {
    return {
      "x": this.point == null ? null : this.point.points.dx,
      "y": this.point == null ? null : this.point.points.dy,
      "time_stamp": this.timeStamp,
    };
  }

  //Convert stored json into DrawPoint
  factory DrawPoint.fromJson(Map<String, dynamic> json) {
    return DrawPoint(
      point: json['x'] == null
          ? null
          : DrawingPoints(
              points: Offset(json['x'], json['y']),
              paint: Paint()
                ..strokeWidth = 3.0
                ..isAntiAlias = true
                ..strokeCap = StrokeCap.butt
                ..color = Colors.red),
      timeStamp: json['time_stamp'],
    );
  }
}
