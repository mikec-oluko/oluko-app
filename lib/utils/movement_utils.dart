import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/constants/theme.dart';
import 'oluko_localizations.dart';

class MovementUtils {
  static Text movementTitle(String title) {
    return Text(
      title,
      textAlign: TextAlign.center,
      style: OlukoFonts.olukoSubtitleFont(customFontWeight: FontWeight.bold),
    );
  }

  static description(String description, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              OlukoLocalizations.get(context, 'description') + ":",
              style: OlukoFonts.olukoSuperBigFont(customFontWeight: FontWeight.bold),
            )),
        Text(
          description,
          style: OlukoFonts.olukoBigFont(customFontWeight: FontWeight.normal, customColor: OlukoColors.white),
        ),
      ],
    );
  }

  static Widget getTextWidget(String text, bool big) {
    TextStyle style;
    if (big) {
      style = OlukoFonts.olukoBigFont(customFontWeight: FontWeight.w400);
    } else {
      style = OlukoFonts.olukoBigFont();
    }
    return Text(
      text,
      style: style,
    );
  }

  static Column labelWithTitle(String title, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: OlukoFonts.olukoBigFont(customFontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: OlukoFonts.olukoBigFont(),
        )
      ],
    );
  }
}
