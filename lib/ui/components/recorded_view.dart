import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/ui/components/course_progress_bar.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:oluko_app/utils/sound_player.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class RecordedView extends StatefulWidget {
  final List<String> records;
  final String record;
  final bool showTicks;
  final PanelController panelController;

  const RecordedView({
    Key key,
    this.records,
    this.record,
    this.showTicks,
    this.panelController,
  }) : super(key: key);

  @override
  _RecordedViewState createState() => _RecordedViewState();
}

class _RecordedViewState extends State<RecordedView> {
  int _totalDuration;
  int _currentDuration;
  double _completedPercentage = 0.0;
  bool _isPlaying = false;
  AudioPlayer audioPlayer = AudioPlayer();
  bool playedOnce = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 75,
      width: ScreenUtils.width(context),
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          SizedBox(width: 5),
          playButton(),
          SizedBox(width: 15),
          Container(width: 200, child: CourseProgressBar(value: _completedPercentage)),
          Expanded(child: SizedBox()),
          Padding(
              padding: EdgeInsets.only(right: 15),
              child: Image.asset(
                'assets/courses/audio_horizontal_vector.png',
                scale: 3.5,
              )),
          widget.showTicks
              ? Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: Image.asset(
                    'assets/courses/coach_tick.png',
                    scale: 5,
                  ))
              : GestureDetector(
                  onTap: () => widget.panelController.open(),
                  child: Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: !OlukoNeumorphism.isNeumorphismDesign
                          ? Image.asset(
                              'assets/courses/bin.png',
                              scale: 16,
                            )
                          : Image.asset(
                              'assets/neumorphic/bin.png',
                              scale: 4,
                            ))),
        ],
      ),
    );
  }

  Widget playButton() {
    return GestureDetector(
        onTap: () async {
          _onPlay(filePath: widget.record);
        },
        child: Stack(alignment: Alignment.center, children: [
          Image.asset(
            'assets/courses/green_circle.png',
            scale: 5.5,
          ),
          Icon(_isPlaying ? Icons.pause : Icons.play_arrow, size: 22, color: OlukoColors.black)
        ]));
  }

  Future<void> _onPlay({String filePath}) async {
    if (!_isPlaying) {
      if (playedOnce) {
        await audioPlayer.resume();
      } else {
        await audioPlayer.play(filePath, isLocal: true);
        setState(() {
          playedOnce = true;
        });
      }

      setState(() {
        _completedPercentage = 0.0;
        _isPlaying = true;
      });

      audioPlayer.onPlayerCompletion.listen((_) {
        setState(() {
          _isPlaying = false;
          _completedPercentage = 0.0;
          playedOnce = false;
        });
      });
      audioPlayer.onDurationChanged.listen((duration) {
        setState(() {
          _totalDuration = duration.inMicroseconds;
        });
      });

      audioPlayer.onAudioPositionChanged.listen((duration) {
        setState(() {
          _currentDuration = duration.inMicroseconds;
          _completedPercentage = _currentDuration.toDouble() / _totalDuration.toDouble();
        });
      });
    } else {
      await audioPlayer.pause();
      setState(() {
        _isPlaying = false;
      });
    }
  }
}
