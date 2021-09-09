import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';

class CoachUserProgressComponent extends StatefulWidget {
  final int progressValue;
  final String nameOfField;
  final bool needPercentage;
  const CoachUserProgressComponent(
      {this.progressValue, this.nameOfField, this.needPercentage = false});

  @override
  _CoachUserProgressComponentState createState() =>
      _CoachUserProgressComponentState();
}

class _CoachUserProgressComponentState
    extends State<CoachUserProgressComponent> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
                image: DecorationImage(
              image: Image.asset(
                'assets/assessment/check_ellipse.png',
                scale: 4,
              ).image,
            )),
            child: Center(
                child: Text(
              widget.needPercentage
                  ? widget.progressValue.toString() + "%"
                  : widget.progressValue.toString(),
              style: OlukoFonts.olukoMediumFont(
                  customColor: OlukoColors.white,
                  custoFontWeight: FontWeight.w500),
            ))),
        Container(
            width: 80,
            child: Text(
              widget.nameOfField,
              style: OlukoFonts.olukoMediumFont(
                  customColor: OlukoColors.grayColor,
                  custoFontWeight: FontWeight.w500),
            )),
      ],
    );
  }
}