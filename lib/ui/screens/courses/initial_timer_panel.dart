import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/ui/components/oluko_primary_button.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_primary_button.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class InitialTimerPanel extends StatefulWidget {
  final PanelController panelController;
  final Function() onShowAgainPressed;

  InitialTimerPanel({this.panelController, this.onShowAgainPressed});

  @override
  _State createState() => _State();
}

class _State extends State<InitialTimerPanel> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(top: 30, right: 30, left: 30),
        decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/courses/gray_background.png'),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        child: Column(children: [
          Text(OlukoLocalizations.get(context, 'pauseWarning'),
              textAlign: TextAlign.left, style: OlukoFonts.olukoBigFont(custoFontWeight: FontWeight.w600, customColor: OlukoColors.white)),
          SizedBox(height: 5),
          startButton(),
          SizedBox(height: 25),
          Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            checkBox(),
            Text(OlukoLocalizations.get(context, 'dontShowAgain'),
                textAlign: TextAlign.center,
                style: OlukoFonts.olukoMediumFont(custoFontWeight: FontWeight.w400, customColor: OlukoColors.primary)),
            Expanded(child: SizedBox()),
            Container(width: 100, child: okButton())
          ]),
        ]));
  }

  Widget checkBox() {
    return Theme(
        data: ThemeData(unselectedWidgetColor: OlukoColors.primary),
        child: Checkbox(
          checkColor: OlukoColors.primary,
          activeColor: Colors.transparent,
          value: isChecked,
          onChanged: (bool value) {
            setState(() {
              isChecked = value;
            });
            widget.onShowAgainPressed();
          },
        ));
  }

  Widget okButton() {
    return OlukoNeumorphism.isNeumorphismDesign
        ? OlukoNeumorphicPrimaryButton(
            title: OlukoLocalizations.get(context, 'ok'),
            onPressed: () {
              widget.panelController.close();
            })
        : OlukoPrimaryButton(
            title: OlukoLocalizations.get(context, 'ok'),
            color: OlukoColors.primary,
            onPressed: () {
              widget.panelController.close();
            });
  }

  Widget startButton() {
    return Stack(alignment: Alignment.center, children: [
      Image.asset(
        'assets/neumorphic/button_shade.png',
        scale: 4.1,
      ),
      Image.asset(
        'assets/neumorphic/record_button.png',
        scale: 7,
      ),
    ]);
  }
}
