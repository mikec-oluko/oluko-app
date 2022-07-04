import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';

class OlukoBlueHeader extends StatelessWidget {
  const OlukoBlueHeader({this.textContent});
  final String textContent;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
        color: OlukoNeumorphismColors.olukoNeumorphicBlueBackgroundColor,
      ),
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Text(textContent,
            overflow: TextOverflow.ellipsis,
            style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.white, customFontWeight: FontWeight.w500)),
      ),
    );
  }
}
