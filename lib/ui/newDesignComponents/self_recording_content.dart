import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_secondary_button.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

import 'oluko_neumorphic_primary_button.dart';

class SelfRecordingContent extends StatefulWidget {
  final Function() onRecordingAction;

  const SelfRecordingContent({this.onRecordingAction});

  @override
  _SelfRecordingContentState createState() => _SelfRecordingContentState();
}

class _SelfRecordingContentState extends State<SelfRecordingContent> {
  @override
  Widget build(BuildContext context) {
    return Container(
        height: 350,
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(OlukoNeumorphism.isNeumorphismDesign ? 20 : 0),
                topRight: Radius.circular(OlukoNeumorphism.isNeumorphismDesign ? 20 : 0)),
            image: DecorationImage(
              image: AssetImage('assets/courses/dialog_background.png'),
              fit: BoxFit.cover,
            )),
        child: Stack(children: [
          Column(children: [
            const SizedBox(height: 80),
            Text(OlukoLocalizations.get(context, 'notificationSegment'),
                textAlign: TextAlign.center, style: OlukoFonts.olukoSuperBigFont(custoFontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: Text(OlukoLocalizations.get(context, 'recordingConfirmation'),
                    textAlign: TextAlign.center,
                    style: OlukoFonts.olukoBigFont(customColor: OlukoColors.grayColor, customFontWeight: FontWeight.w400))),
            const SizedBox(height: 100),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OlukoNeumorphicSecondaryButton(
                        title: OlukoLocalizations.get(context, 'no'),
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                    const SizedBox(width: 20),
                    OlukoNeumorphicPrimaryButton(
                      title: OlukoLocalizations.get(context, 'yes'),
                      onPressed: () {
                        widget.onRecordingAction();
                      },
                    )
                  ],
                )),
          ]),
          Align(
              alignment: Alignment.topRight,
              child: Padding(
                  padding: EdgeInsets.only(top: 15, right: 15),
                  child: IconButton(
                      icon: const Icon(Icons.close, color: OlukoNeumorphism.isNeumorphismDesign ? OlukoColors.primary : OlukoColors.white),
                      onPressed: () => Navigator.pop(context))))
        ]));
  }
}
