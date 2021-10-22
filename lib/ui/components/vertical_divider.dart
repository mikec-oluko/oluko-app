import 'package:flutter/material.dart';

class VerticalDivider extends StatelessWidget {
  final double width;
  final double height;
  const VerticalDivider({ this.width, this.height }) : super();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/courses/vertical_divider.png',
      height: height,
      width: width,
    );
  }
}