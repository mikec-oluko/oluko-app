import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/challenge.dart';
import 'package:oluko_app/models/submodels/audio.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/ui/screens/courses/audio_dialog_content.dart';
import 'package:oluko_app/ui/screens/courses/audio_panel.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class ModalAudio extends StatefulWidget {
  List<UserResponse> users;
  List<Audio> audios;
  Challenge challenge;
  AudioPlayer audioPlayer;
  final bool comesFromSegmentDetail;
  final Function(int, Challenge) onAudioPressed;
  PanelController panelController;

  ModalAudio({this.panelController, this.comesFromSegmentDetail, this.users, this.audios, this.onAudioPressed, this.challenge, this.audioPlayer});

  @override
  _ModalAudioState createState() => _ModalAudioState();
}

class _ModalAudioState extends State<ModalAudio> {
  List<Audio> _audios = [];

  @override
  void initState() {
    _audios = widget.audios;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [OlukoNeumorphismColors.initialGradientColorDark, OlukoNeumorphismColors.finalGradientColorDark],
          ),
        ),
        width: MediaQuery.of(context).size.width,
        height: 150,
        child: audioSection());
  }

  Widget audioSection() {
    if (_audios.length == 1) {
      return AudioDialogContent(
          coach: widget.users != null ? widget.users[0] : null, audio: _audios[0], panelController: widget.panelController, audioPlayer: widget.audioPlayer);
    } else {
      return AudioPanel(
        onAudioPressed: (int index) => widget.onAudioPressed(index, widget.challenge),
        coaches: widget.users,
        audios: _audios,
        audioPlayer: widget.audioPlayer,
        comesFromSegmentDetail: widget.comesFromSegmentDetail,
      );
    }
  }
}
