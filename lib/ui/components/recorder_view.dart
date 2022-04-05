import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/utils/sound_recorder.dart';

class RecorderView extends StatefulWidget {
  final SoundRecorder recorder;
  final Function onSaved;
  final Function startTimer;

  const RecorderView({Key key, this.recorder, this.onSaved, this.startTimer}) : super(key: key);
  @override
  _RecorderViewState createState() => _RecorderViewState();
}

class _RecorderViewState extends State<RecorderView> {
  @override
  Widget build(BuildContext context) {
    final isRecording = widget.recorder.isRecording;
    return GestureDetector(
        onTap: () async {
          widget.startTimer();
          final isRecording = await widget.recorder.toggleRecording();
          if (widget.recorder.isStopped) {
            widget.onSaved();
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
            scale: 6,
          ),
          Icon(isRecording ? Icons.stop : Icons.mic,
              size: 23, color: OlukoNeumorphism.isNeumorphismDesign ? OlukoColors.white : OlukoColors.black)
        ]));
  }
}
