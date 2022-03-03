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
    FontWeight fontWeight = bold ? FontWeight.bold : FontWeight.w400;
    Color fontColor = isNeumorphic ? OlukoColors.grayColor : Colors.white;
    return Text(
      title,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.start,
      style: reduceFontSize
          ? MediaQuery.of(context).size.width < 400
              ? OlukoFonts.olukoTitleFont(custoFontWeight: fontWeight,customColor: fontColor)
              : OlukoFonts.olukoSuperBigFont(custoFontWeight: fontWeight,customColor: fontColor)
          : OlukoFonts.olukoSuperBigFont(custoFontWeight: fontWeight,customColor: fontColor),
    );
  }
}
