import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TitleHeader extends StatelessWidget {
  final String title;
  final bool bold;

  TitleHeader(this.title, {this.bold = false, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      textAlign: TextAlign.start,
      style: TextStyle(
          fontSize: 30,
          fontWeight: bold ? FontWeight.bold : FontWeight.w200,
          color: Colors.white),
    );
  }
}
