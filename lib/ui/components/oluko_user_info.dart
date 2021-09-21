import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';

class OlukoUserInfoWidget extends StatefulWidget {
  final String title;
  final String value;

  OlukoUserInfoWidget({this.title, this.value});

  @override
  _OlukoUserInfoWidgetState createState() => _OlukoUserInfoWidgetState();
}

class _OlukoUserInfoWidgetState extends State<OlukoUserInfoWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                border: Border.all(width: 1.0, color: OlukoColors.grayColor)),
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 8,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text(
                      widget.title,
                      style: OlukoFonts.olukoMediumFont(
                          customColor: OlukoColors.primary),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text(
                      widget.value != 'null' ? widget.value : '-',
                      style: OlukoFonts.olukoBigFont(
                        custoFontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
