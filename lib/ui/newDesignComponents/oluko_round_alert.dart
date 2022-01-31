import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:oluko_app/constants/theme.dart';

class OlukoRoundAlert extends StatefulWidget {
  final String text;

  const OlukoRoundAlert({
    @required this.text,
  }) : super();

  @override
  _OlukoRoundAlertState createState() => _OlukoRoundAlertState();
}

class _OlukoRoundAlertState extends State<OlukoRoundAlert> {
  Color buttonColor = OlukoColors.primary;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Image.asset(
        'assets/neumorphic/alert.png',
        fit: BoxFit.cover,
      ),
      Text(widget.text, style: OlukoFonts.olukoBigFont(custoFontWeight: FontWeight.w400, customColor: OlukoColors.grayColor))
    ]);
  }
}
