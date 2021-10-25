import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TitleBody extends StatelessWidget {
  final String title;
  final bool bold;

  TitleBody(this.title, {this.bold = false, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      textAlign: TextAlign.start,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
          fontSize: 22,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
          color: Colors.white),
    );
  }
}
