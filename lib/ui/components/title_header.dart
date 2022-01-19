import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';

class TitleHeader extends StatelessWidget {
  final String title;
  final bool bold;
  final bool reduceFontSize;
  final bool isNeumorphic;

  TitleHeader(this.title, {this.bold = false, this.isNeumorphic = false, this.reduceFontSize = false, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.start,
      style: TextStyle(
          fontSize: reduceFontSize
              ? MediaQuery.of(context).size.width < 400
                  ? 20
                  : 30
              : 30,
          fontWeight: bold ? FontWeight.bold : FontWeight.w200,
          color: isNeumorphic ? OlukoColors.grayColor : Colors.white),
    );
  }
}
