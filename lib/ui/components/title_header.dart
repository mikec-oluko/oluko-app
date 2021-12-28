import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';

class TitleHeader extends StatelessWidget {
  final String title;
  final bool bold;
  final bool isNeumorphic;

  TitleHeader(this.title, {this.bold = false, this.isNeumorphic = false, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      textAlign: TextAlign.start,
      style: TextStyle(
          fontSize: 30, fontWeight: bold ? FontWeight.bold : FontWeight.w200, color: isNeumorphic ? OlukoColors.grayColor : Colors.white),
    );
  }
}
