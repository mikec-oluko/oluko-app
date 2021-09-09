import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:oluko_app/ui/screens/videos/draw.dart';

class DrawPoint {
  DrawingPoints point;
  int miliseconds;

  DrawPoint({this.point, this.miliseconds});

  Map<String, dynamic> toJson() {
    return {
      "x": this.point == null ? null : this.point.points.dx,
      "y": this.point == null ? null : this.point.points.dy,
      "time_stamp": this.miliseconds,
    };
  }

  //Convert stored json into DrawPoint
  factory DrawPoint.fromJson(Map<String, dynamic> json) {
    return DrawPoint(
      point: json['x'] == null
          ? null
          : DrawingPoints(
              points: Offset(double.tryParse(json['x'].toString()), double.tryParse(json['y'].toString())),
              paint: Paint()
                ..strokeWidth = 3.0
                ..isAntiAlias = true
                ..strokeCap = StrokeCap.butt
                ..color = Colors.red),
      miliseconds: json['time_stamp'].toString() as int,
    );
  }
}
