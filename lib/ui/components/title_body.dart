import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';

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
      style: OlukoFonts.olukoBigFont(customFontWeight: bold ? FontWeight.w700 : FontWeight.w400),
    );
  }
}
