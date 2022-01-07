import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/models/challenge.dart';
import 'package:oluko_app/models/submodels/audio.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/ui/screens/courses/audio_panel.dart';

class ModalAudio extends StatefulWidget {
  List<UserResponse> users;
  List<Audio> audios;
  Challenge challenge;
  AudioPlayer audioPlayer;
  final Function(int, Challenge) onAudioPressed;

  ModalAudio({this.users, this.audios, this.onAudioPressed, this.challenge, this.audioPlayer});

  @override
  _ModalAudioState createState() => _ModalAudioState();
}

class _ModalAudioState extends State<ModalAudio> {

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/courses/gray_background.png'),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        width: MediaQuery.of(context).size.width,
        height: 150,
        child: audioSection());
  }

  Widget audioSection() {
    return AudioPanel(
      onAudioPressed: (int index) => widget.onAudioPressed(index, widget.challenge),
      coaches: widget.users,
      audios: widget.audios,
      audioPlayer: widget.audioPlayer,
    );
  }


}