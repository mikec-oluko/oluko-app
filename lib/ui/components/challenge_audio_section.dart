import 'dart:io';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/blocs/audio_bloc.dart';
import 'package:oluko_app/blocs/challenge/panel_audio_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/ui/components/oluko_primary_button.dart';
import 'package:oluko_app/ui/components/recorded_view.dart';
import 'package:oluko_app/ui/components/recorder_view.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_primary_button.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/sound_recorder.dart';
import 'package:oluko_app/utils/time_converter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChallengeAudioSection extends StatefulWidget {
  final UserResponse user;
  final String challengeId;
  final SoundRecorder recorder;
  final String userName;
  final PanelController panelController;

  ChallengeAudioSection({this.challengeId, this.user, this.recorder, this.userName, this.panelController});

  @override
  _State createState() => _State();
}

class _State extends State<ChallengeAudioSection> {
  double _neumorphicMaxHeight = 250;
  double _maxHeight = 140;
  bool submitted = false;
  bool audioRecorded = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PanelAudioBloc, PanelAudioState>(builder: (context, state) {
      if (state is PanelAudioSuccess) {
        audioRecorded = state.audioRecorded;
      }
      return audioRecorded ? audioRecordedSection() : audioRecorderSection();
    });
  }

  Widget audioRecordedSection() {
    return OlukoNeumorphism.isNeumorphismDesign
        ? Container(
            height: !submitted ? _neumorphicMaxHeight : 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadiusDirectional.vertical(top: Radius.circular(20)),
              image: DecorationImage(
                image: AssetImage('assets/courses/dialog_background.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: _recordedContent())
        : Container(height: !submitted ? _maxHeight : 76, color: Colors.black, child: _recordedContent());
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
                !submitted
                    ? Text(
                        OlukoLocalizations.get(context, 'voiceMessages'),
                        style: OlukoFonts.olukoBigFont(customColor: OlukoColors.white),
                      )
                    : SizedBox(),
                SizedBox(height: !submitted ? 15 : 0),
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
                  RecordedView(record: widget.recorder.audioUrl, showTicks: submitted, panelController: widget.panelController),
                ]),
                SizedBox(height: 15)
              ]),
            )
          : RecordedView(record: widget.recorder.audioUrl, showTicks: submitted, panelController: widget.panelController),
      !submitted ? _saveButton() : SizedBox()
    ]);
  }

  _saveAudio() {
    BlocProvider.of<AudioBloc>(context)..saveAudio(File(widget.recorder.audioUrl), widget.user, widget.challengeId);
    setState(() {
      submitted = true;
    });
  }

  _onRecordCompleted() {
    BlocProvider.of<PanelAudioBloc>(context).deleteAudio(true);
  }

  Widget _saveButton() {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: Container(
            height: 50,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                !OlukoNeumorphism.isNeumorphismDesign
                    ? OlukoPrimaryButton(
                        title: OlukoLocalizations.get(context, 'saveFor') + widget.userName,
                        onPressed: () {
                          _saveAudio();
                        },
                      )
                    : OlukoNeumorphicPrimaryButton(
                        isExpanded: true,
                        thinPadding: true,
                        title: OlukoLocalizations.of(context).find('saveFor') + widget.userName,
                        onPressed: () {
                          _saveAudio();
                        },
                      )
              ],
            )));
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
            Expanded(child: SizedBox()),
            Text(
              OlukoLocalizations.get(context, 'recordAMessage') + widget.userName,
              textAlign: TextAlign.left,
              style: OlukoFonts.olukoBigFont(custoFontWeight: FontWeight.normal, customColor: OlukoColors.grayColor),
            ),
            RecorderView(
              recorder: widget.recorder,
              onSaved: () => _onRecordCompleted(),
            )
          ]))
    ]);
  }
}