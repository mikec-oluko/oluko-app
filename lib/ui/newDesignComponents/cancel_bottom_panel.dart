import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_primary_button.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_text_button.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class CancelBottomPanel extends StatefulWidget {
  final String title;
  final String text;
  final String primaryButtonTxt;
  final String textButtonTxt;
  final Function() primaryButtonAction;
  final Function() textButtonAction;

  CancelBottomPanel({this.primaryButtonAction, this.textButtonAction, this.text, this.textButtonTxt, this.title, this.primaryButtonTxt});

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<CancelBottomPanel> {
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 32),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          gradient: OlukoNeumorphism.olukoNeumorphicGradientDark(),
        ),
        child: Column(crossAxisAlignment: OlukoNeumorphism.isNeumorphismDesign ? CrossAxisAlignment.start : CrossAxisAlignment.center, children: [
          SizedBox(height: !OlukoNeumorphism.isNeumorphismDesign ? 10 : 30),
          getTitle(),
          SizedBox(height: !OlukoNeumorphism.isNeumorphismDesign ? 5 : 15),
          getText(),
          SizedBox(height: !OlukoNeumorphism.isNeumorphismDesign ? 25 : 40),
          bottomButtons(),
        ]));
  }

  Widget getTitle() {
    return Text(
      widget.title,
      style: OlukoFonts.olukoBigFont(customColor: OlukoColors.white),
    );
  }

  Widget getText() {
    return Text(widget.text,
        textAlign: !OlukoNeumorphism.isNeumorphismDesign ? TextAlign.center : TextAlign.start,
        style: OlukoFonts.olukoBigFont(customFontWeight: FontWeight.w400, customColor: OlukoColors.grayColor));
  }

  Widget bottomButtons() {
    return Row(
      children: [
        Expanded(child: SizedBox()),
        OlukoNeumorphicTextButton(
            title: widget.textButtonTxt,
            onPressed: () {
              widget.textButtonAction();
            }),
        OlukoNeumorphicPrimaryButton(
            title: widget.primaryButtonTxt,
            onPressed: () {
              widget.primaryButtonAction();
            })
      ],
    );
  }
}
