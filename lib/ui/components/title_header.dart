import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class TitleHeader extends StatelessWidget {
  final String title;
  final bool bold;
  final bool reduceFontSize;
  final bool isNeumorphic;

  TitleHeader(this.title, {this.bold = false, this.isNeumorphic = false, this.reduceFontSize = false, Key key}) : super(key: key);

  @override
Widget build(BuildContext context) {
  final FontWeight fontWeight = bold ? FontWeight.bold : FontWeight.w500;
  final Color fontColor = isNeumorphic ? OlukoColors.grayColor : Colors.white;

  final style = reduceFontSize
    ? ScreenUtils.smallScreen(context)
        ? OlukoFonts.olukoTitleFont(customFontWeight: fontWeight, customColor: fontColor)
        : OlukoFonts.olukoSuperBigFont(customFontWeight: fontWeight, customColor: fontColor)
    : OlukoFonts.olukoSuperBigFont(customFontWeight: fontWeight, customColor: fontColor);

  return LayoutBuilder(
    builder: (BuildContext context, BoxConstraints constraints) {
      String cutTitle = title;
      
      final painter = TextPainter(
        text: TextSpan(text: title, style: style),
        maxLines: 1,
        textDirection: TextDirection.ltr,
      );
  
      painter.layout(minWidth: 0, maxWidth: constraints.maxWidth);
      if (painter.didExceedMaxLines) {
        for (int i = title.length; i > 0; i--) {
          String titlePart = title.substring(0, i);
          titlePart += '...';
          final textPainter = TextPainter(
            text: TextSpan(text: titlePart, style: style),
            maxLines: 1,
            textDirection: TextDirection.ltr,
          );
  
          textPainter.layout(minWidth: 0, maxWidth: constraints.maxWidth);
          if (!textPainter.didExceedMaxLines) {
            cutTitle = titlePart;
            break;
          }
        }
      }
  
      return Text(
        cutTitle,
        textAlign: TextAlign.start,
        style: style,
      );
    }
  );
}
}
