import 'dart:async';
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
  final String userFirstName;
  final PanelController panelController;

  ChallengeAudioSection({this.challengeId, this.user, this.recorder, this.userFirstName, this.panelController});

  @override
  _State createState() => _State();
}

class _State extends State<ChallengeAudioSection> {
  double _neumorphicMaxHeight = 250;
  double _maxHeight = 140;
  bool submitted = false;
  bool audioRecorded = false;
  bool isRecording = false;
  Timer _timer;
  Duration duration = Duration();
  Duration durationToSave = Duration();
  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PanelAudioBloc, PanelAudioState>(builder: (context, state) {
      if (state is PanelAudioSuccess) {
        audioRecorded = state.audioRecorded;
        if (audioRecorded && state.stopRecording || !audioRecorded && state.stopRecording) {
          playAudioTimer(state.stopRecording);
          if (!audioRecorded) {
            widget.recorder.dispose();
            widget.recorder.init();
          }
        }
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
      if (!OlukoNeumorphism.isNeumorphismDesign)
        const Divider(
          height: 1,
          color: OlukoColors.divider,
          thickness: 1.5,
          indent: 0,
          endIndent: 0,
        )
      else
        SizedBox(),
      if (OlukoNeumorphism.isNeumorphismDesign)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 10),
            if (!submitted)
              Text(
                OlukoLocalizations.get(context, 'voiceMessages'),
                style: OlukoFonts.olukoBigFont(customColor: OlukoColors.white),
              )
            else
              SizedBox(),
            SizedBox(height: !submitted ? 15 : 0),
            Stack(alignment: AlignmentDirectional.center, children: [
              Stack(alignment: AlignmentDirectional.bottomEnd, children: [
                Image.asset(
                  'assets/neumorphic/audio_rectangle.png',
                  scale: 3.5,
                ),
                OlukoNeumorphism.isNeumorphismDesign
                    ? SizedBox()
                    : Padding(
                        padding: const EdgeInsets.only(right: 15, bottom: 10),
                        child: Text(
                          TimeConverter.getDateAndTimeOnStringFormat(dateToFormat: Timestamp.now(), context: context),
                          style: OlukoFonts.olukoSmallFont(customColor: OlukoColors.white),
                        )),
              ]),
              RecordedView(
                record: widget.recorder.audioUrl,
                showTicks: submitted,
                panelController: widget.panelController,
                secondsRecorded: TimeConverter.durationToString(durationToSave),
              ),
            ]),
            const SizedBox(height: 15)
          ]),
        )
      else
        RecordedView(record: widget.recorder.audioUrl, showTicks: submitted, panelController: widget.panelController),
      if (!submitted) _saveButton() else const SizedBox()
    ]);
  }

  _saveAudio() {
    BlocProvider.of<AudioBloc>(context).saveAudio(File(widget.recorder.audioUrl), widget.user, widget.challengeId);
    setState(() {
      submitted = true;
    });
    BlocProvider.of<PanelAudioBloc>(context).emitDefaultState();
  }

  _onRecordCompleted() {
    BlocProvider.of<PanelAudioBloc>(context).deleteAudio(true, true);
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
                        title: OlukoLocalizations.get(context, 'saveFor') + widget.userFirstName,
                        onPressed: () {
                          _saveAudio();
                        },
                      )
                    : OlukoNeumorphicPrimaryButton(
                        isExpanded: true,
                        thinPadding: true,
                        title: OlukoLocalizations.of(context).find('saveFor') + widget.userFirstName,
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
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            if (isRecording)
              Text(
                TimeConverter.durationToString(duration),
                style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.primary, customFontWeight: FontWeight.bold),
              )
            else
              SizedBox(),
            Text(
              isRecording
                  ? OlukoLocalizations.get(context, 'pressToCancel')
                  : OlukoLocalizations.get(context, 'recordAMessage') + widget.userFirstName,
              textAlign: TextAlign.left,
              style: OlukoFonts.olukoBigFont(customFontWeight: FontWeight.normal, customColor: OlukoColors.grayColor),
            ),
            isRecording
                ? GestureDetector(
                    onTap: () => widget.panelController.open(),
                    child: Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: Image.asset(
                          'assets/neumorphic/bin.png',
                          scale: 4,
                        )))
                : SizedBox(),
            RecorderView(
              recorder: widget.recorder,
              onSaved: () => _onRecordCompleted(),
              playAudioTimer: () => playAudioTimer(false),
              isRecording: isRecording,
            )
          ]))
    ]);
  }

  void playAudioTimer(bool playAudioTimer) {
    const oneSec = const Duration(seconds: 1);
    if (playAudioTimer) {
      _timer.cancel();
      durationToSave = duration;
      duration = Duration.zero;
      isRecording = false;
    } else {
      isRecording = true;
      _timer = Timer.periodic(oneSec, (_) => addTime());
    }
  }

  addTime() {
    final addSeconds = 1;
    setState(() {
      final seconds = duration.inSeconds + addSeconds;
      duration = Duration(seconds: seconds);
    });
  }
}
