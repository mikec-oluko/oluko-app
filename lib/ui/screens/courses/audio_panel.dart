import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/submodels/audio.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/ui/screens/courses/audio_section.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class AudioPanel extends StatefulWidget {
  final List<UserResponse> coaches;
  final List<Audio> audios;
  final Function(int) onAudioPressed;
  AudioPlayer audioPlayer;

  AudioPanel({this.coaches, this.audios, this.onAudioPressed, this.audioPlayer});

  @override
  _State createState() => _State();
}

class _State extends State<AudioPanel> {
  List<Widget> _audioWidgets = [];

  @override
  void initState() {
    _audioWidgets = getAudioWidgets();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 25),
        decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/courses/gray_background.png'),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        child: Column(children: [
          Padding(
              padding: EdgeInsets.only(top: 20, bottom: 10),
              child: Image.asset(
                'assets/courses/horizontal_vector.png',
                scale: 3,
              )),
          Padding(
            padding: const EdgeInsets.only(top: 15, bottom: 5),
            child: Text(
              OlukoLocalizations.get(context, 'voiceMessages'),
              style: OlukoFonts.olukoSuperBigFont(custoFontWeight: FontWeight.w500, customColor: OlukoColors.white),
            ),
          ),
          Container(height: 370, child: ListView(children: _audioWidgets))
        ]));
  }

  List<Widget> getAudioWidgets() {
    List<Widget> widgets = [];
    if (widget.audios == null) {
      return widgets;
    }
    for (int i = 0; i < widget.audios.length; i++) {
      widgets.add(AudioSection(
          showTopDivider: i != 0,
          coach: widget.coaches == null ? null : widget.coaches[i],
          audio: widget.audios[i],
          audioPlayer: widget.audioPlayer,
          removeAudioFromList: () => _removeAudioFromList(i),
          onAudioPressed: () => widget.onAudioPressed(i)));
    }
    return widgets;
  }

  _removeAudioFromList(int index) {
    setState(() {
      _audioWidgets.removeAt(index);
    });
  }
}
