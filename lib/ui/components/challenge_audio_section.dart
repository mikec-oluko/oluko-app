import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/ui/components/oluko_primary_button.dart';
import 'package:oluko_app/ui/components/recorded_view.dart';
import 'package:oluko_app/ui/components/recorder_view.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_primary_button.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/sound_recorder.dart';
import 'package:oluko_app/utils/time_converter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class ChallengeAudioSection extends StatefulWidget {
  final bool audioRecorded;
  final bool submitted;
  final SoundRecorder recorder;
  final String userName;
  final Function() onSaveAudioPressed;
  final Function() onRecordCompleted;
  final PanelController panelController;

  ChallengeAudioSection(
      {this.audioRecorded,
      this.submitted,
      this.recorder,
      this.userName,
      this.onSaveAudioPressed,
      this.panelController,
      this.onRecordCompleted});

  @override
  _State createState() => _State();
}

class _State extends State<ChallengeAudioSection> {
  double _neumorphicMaxHeight = 250;
  double _maxHeight = 140;

  @override
  Widget build(BuildContext context) {
    return widget.audioRecorded ? audioRecordedSection() : audioRecorderSection();
  }

  Widget audioRecordedSection() {
    return OlukoNeumorphism.isNeumorphismDesign
        ? Container(
            height: !widget.submitted ? _neumorphicMaxHeight : 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadiusDirectional.vertical(top: Radius.circular(20)),
              image: DecorationImage(
                image: AssetImage('assets/courses/dialog_background.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: _recordedContent())
        : Container(height: !widget.submitted ? _maxHeight : 76, color: Colors.black, child: _recordedContent());
  }

  Widget _recordedContent() {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      !OlukoNeumorphism.isNeumorphismDesign
          ? Divider(
              height: 1,
              color: OlukoColors.divider,
              thickness: 1.5,
              indent: 0,
              endIndent: 0,
            )
          : SizedBox(),
      OlukoNeumorphism.isNeumorphismDesign
          ? Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SizedBox(height: 10),
                !widget.submitted
                    ? Text(
                        'Voice messages',
                        style: OlukoFonts.olukoBigFont(customColor: OlukoColors.white),
                      )
                    : SizedBox(),
                SizedBox(height: !widget.submitted ? 15 : 0),
                Stack(alignment: AlignmentDirectional.center, children: [
                  Stack(alignment: AlignmentDirectional.bottomEnd, children: [
                    Image.asset(
                      'assets/neumorphic/audio_rectangle.png',
                      scale: 3.5,
                    ),
                    Padding(
                        padding: EdgeInsets.only(right: 15, bottom: 10),
                        child: Text(
                          TimeConverter.getDateAndTimeOnStringFormat(dateToFormat: Timestamp.now(), context: context),
                          style: OlukoFonts.olukoSmallFont(customColor: OlukoColors.white),
                        )),
                  ]),
                  RecordedView(record: widget.recorder.audioUrl, showTicks: widget.submitted, panelController: widget.panelController),
                ]),
                SizedBox(height: 15)
              ]),
            )
          : RecordedView(record: widget.recorder.audioUrl, showTicks: widget.submitted, panelController: widget.panelController),
      !widget.submitted ? _saveButton() : SizedBox()
    ]);
  }

  Widget _saveButton() {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            !OlukoNeumorphism.isNeumorphismDesign
                ? OlukoPrimaryButton(
                    title: OlukoLocalizations.get(context, 'saveFor') + widget.userName,
                    onPressed: () {
                      widget.onSaveAudioPressed();
                    },
                  )
                : OlukoNeumorphicPrimaryButton(
                    isExpanded: true,
                    thinPadding: true,
                    title: OlukoLocalizations.of(context).find('saveFor') + widget.userName,
                    onPressed: () {
                      widget.onSaveAudioPressed();
                    },
                  )
          ],
        ));
  }

  Widget audioRecorderSection() {
    return OlukoNeumorphism.isNeumorphismDesign
        ? Container(
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadiusDirectional.vertical(top: Radius.circular(20)),
              image: DecorationImage(
                image: AssetImage('assets/courses/dialog_background.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: _recorderContent())
        : Container(height: 76, child: _recorderContent());
  }

  Widget _recorderContent() {
    return Column(children: [
      !OlukoNeumorphism.isNeumorphismDesign
          ? Divider(
              height: 1,
              color: OlukoColors.divider,
              thickness: 1.5,
              indent: 0,
              endIndent: 0,
            )
          : SizedBox(),
      Padding(
          padding: OlukoNeumorphism.isNeumorphismDesign
              ? EdgeInsets.only(right: 0, left: 15, top: 0, bottom: 15)
              : EdgeInsets.only(right: 15, left: 15, top: 15, bottom: 15),
          child: Row(children: [
            Text(
              OlukoLocalizations.get(context, 'recordAMessage') + widget.userName,
              textAlign: TextAlign.left,
              style: OlukoFonts.olukoBigFont(custoFontWeight: FontWeight.normal),
            ),
            Expanded(child: SizedBox()),
            RecorderView(
              recorder: widget.recorder,
              onSaved: widget.onRecordCompleted,
            )
          ]))
    ]);
  }
}
