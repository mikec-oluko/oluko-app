import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/ui/components/oluko_primary_button.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class InitialTimerPanel extends StatefulWidget {
  final PanelController panelController;

  InitialTimerPanel({this.panelController});

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
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        child: Column(children: [
          startButton(),
          SizedBox(height: 30),
          Text(OlukoLocalizations.of(context).find('pauseWarning'),
              textAlign: TextAlign.center,
              style: OlukoFonts.olukoBigFont(
                  custoFontWeight: FontWeight.w400,
                  customColor: OlukoColors.coral)),
          SizedBox(height: 5),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(OlukoLocalizations.of(context).find('dontShowAgain'),
                textAlign: TextAlign.center,
                style: OlukoFonts.olukoBigFont(
                    custoFontWeight: FontWeight.w400,
                    customColor: OlukoColors.white)),
            Theme(
                data: ThemeData(unselectedWidgetColor: OlukoColors.primary),
                child: Checkbox(
                  checkColor: OlukoColors.primary,
                  activeColor: Colors.transparent,
                  value: isChecked,
                  onChanged: (bool value) {
                    setState(() {
                      isChecked = value;
                    });
                  },
                ))
          ]),
          SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 80),
            child: Row(children: [
              OlukoPrimaryButton(
                  title: OlukoLocalizations.of(context).find('ok'),
                  color: OlukoColors.primary,
                  onPressed: () {
                    widget.panelController.close();
                  })
            ]),
          )
        ]));
  }

  Widget startButton() {
    return GestureDetector(
        /*onTap: () {
          Navigator.pushNamed(context, routeLabels[RouteEnum.segmentRecording],
              arguments: {
                'segmentIndex': widget.segmentIndex,
                'classIndex': widget.classIndex,
                'courseEnrollment': widget.courseEnrollment,
                'workoutType': WorkoutType.segmentWithRecording,
                'segments': widget.segments,
              });
        },*/
        child: Stack(alignment: Alignment.center, children: [
      Image.asset(
        'assets/courses/oval.png',
        scale: 4,
      ),
      Image.asset(
        'assets/courses/pause_button.png',
        scale: 4,
      ),
    ]));
  }
}
