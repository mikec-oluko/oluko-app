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
          padding:
              OlukoNeumorphism.isNeumorphismDesign ? const EdgeInsets.symmetric(horizontal: 20, vertical: 10) : const EdgeInsets.all(10.0),
          child: Container(
            decoration: BoxDecoration(
                borderRadius:
                    OlukoNeumorphism.isNeumorphismDesign ? BorderRadius.all(Radius.circular(15.0)) : BorderRadius.all(Radius.circular(5.0)),
                border: OlukoNeumorphism.isNeumorphismDesign ? Border.symmetric() : Border.all(width: 1.0, color: OlukoColors.grayColor),
                color:
                    OlukoNeumorphism.isNeumorphismDesign ? OlukoNeumorphismColors.olukoNeumorphicGreyBackgroundFlat : Colors.transparent),
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 8,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: OlukoNeumorphism.isNeumorphismDesign ? 20 : 10),
                    child: Text(
                      widget.title,
                      style: OlukoFonts.olukoMediumFont(
                          customColor: OlukoNeumorphism.isNeumorphismDesign ? OlukoColors.grayColor : OlukoColors.primary),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: OlukoNeumorphism.isNeumorphismDesign ? 20 : 10),
                    child: Text(
                      widget.value != 'null' ? widget.value : '-',
                      style: OlukoFonts.olukoBigFont(
                        customFontWeight: FontWeight.w500,
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
