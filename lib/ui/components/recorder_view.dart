import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/challenge/panel_audio_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/utils/sound_recorder.dart';

class RecorderView extends StatefulWidget {
  final SoundRecorder recorder;
  final Function onSaved;
  final Function playAudioTimer;
  bool isRecording;

  RecorderView({Key key, this.recorder, this.onSaved, this.playAudioTimer, this.isRecording}) : super(key: key);
  @override
  _RecorderViewState createState() => _RecorderViewState();
}

class _RecorderViewState extends State<RecorderView> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () async {
          final isRecording = await widget.recorder.toggleRecording();
          if (widget.recorder.isStopped) {
            widget.onSaved();
          }
          if (widget.recorder.isRecording) {
            BlocProvider.of<PanelAudioBloc>(context).emitDefaultState();
            widget.playAudioTimer();
          }
          setState(() {});
        },
        child: Stack(alignment: Alignment.center, children: [
          OlukoNeumorphism.isNeumorphismDesign
              ? Image.asset(
                  'assets/neumorphic/audio_circle.png',
                  scale: 4,
                )
              : SizedBox(),
          Image.asset(
            'assets/courses/green_circle.png',
            scale: widget.isRecording ? 3 : 6,
          ),
          Icon(Icons.mic,
              size: widget.isRecording ? 50 : 23, color: OlukoNeumorphism.isNeumorphismDesign ? OlukoColors.white : OlukoColors.black)
        ]));
  }
}
