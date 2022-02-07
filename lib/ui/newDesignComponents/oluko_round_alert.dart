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
    return Stack(alignment: AlignmentDirectional.center, children: [
      Image.asset(
        'assets/neumorphic/alert.png',
        scale: 3,
        fit: BoxFit.cover,
      ),
      Container(
          width: 160,
          child: Center(
              child:
                  Text(widget.text, 
                  textAlign: TextAlign.center,
                  style: OlukoFonts.olukoBigFont(custoFontWeight: FontWeight.w400, customColor: OlukoColors.grayColor))))
    ]);
  }
}
