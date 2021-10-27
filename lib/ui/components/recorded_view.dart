import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/ui/components/course_progress_bar.dart';
import 'package:oluko_app/utils/screen_utils.dart';
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
  int _selectedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return widget.record == null
        ? Center(child: Text('No records yet'))
        : Container(
            height: 75,
            width: ScreenUtils.width(context),
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                playButton(),
                SizedBox(width: 15),
                Container(
                    width: 220,
                    child: CourseProgressBar(value: _completedPercentage)),
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
                            child: Image.asset(
                              'assets/courses/bin.png',
                              scale: 16,
                            ))),
              ],
            ),
          );
  }

  Widget playButton() {
    return GestureDetector(
        onTap: () {
          _onPlay(filePath: widget.record);
        },
        child: Stack(alignment: Alignment.center, children: [
          Image.asset(
            'assets/courses/green_circle.png',
            scale: 5.5,
          ),
          Icon(_isPlaying ? Icons.pause : Icons.play_arrow,
              size: 26, color: OlukoColors.black)
        ]));
  }

  Future<void> _onPlay({String filePath}) async {
    AudioPlayer audioPlayer = AudioPlayer();

    if (!_isPlaying) {
      audioPlayer.play(filePath, isLocal: true);
      setState(() {
        _completedPercentage = 0.0;
        _isPlaying = true;
      });

      audioPlayer.onPlayerCompletion.listen((_) {
        setState(() {
          _isPlaying = false;
          _completedPercentage = 0.0;
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
          _completedPercentage =
              _currentDuration.toDouble() / _totalDuration.toDouble();
        });
      });
    } else {
      audioPlayer.pause();
      setState(() {
        _isPlaying = false;
      });
    }
  }
}
