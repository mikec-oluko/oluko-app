import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/blocs/story_list_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/challenge.dart';
import 'package:oluko_app/models/submodels/audio.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/ui/components/course_progress_bar.dart';
import 'package:oluko_app/ui/components/stories_item.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class AudioDialogContent extends StatefulWidget {
  final UserResponse coach;
  final Audio audio;
  PanelController panelController;
  AudioPlayer audioPlayer;

  AudioDialogContent({this.coach, this.audio, this.panelController, this.audioPlayer});

  @override
  _State createState() => _State();
}

class _State extends State<AudioDialogContent> {
  int _totalDuration;
  int _currentDuration;
  double _completedPercentage = 0.0;
  bool _isPlaying = false;
  bool playedOnce = false;

  @override
  void dispose() {
    widget.audioPlayer.stop();
    super.dispose();
  }

  Widget audioSlider() {
    return Container(
        width: 200, child: Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: CourseProgressBar(value: _completedPercentage)));
  }

  @override
  Widget build(BuildContext context) {
    return audioDialogContent(context, widget.coach);
  }

  Widget audioDialogContent(BuildContext context, UserResponse coach) {
    return ClipRRect(
      borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      child: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
            image: AssetImage("assets/courses/dialog_background.png"),
            fit: BoxFit.cover,
          )),
          child: Stack(children: [
            Center(
                child: Column(children: [
              SizedBox(height: 45),
              Stack(alignment: Alignment.bottomCenter, children: [
                StoriesItem(maxRadius: 65, imageUrl: coach == null ? widget.audio.userAvatarThumbnail : coach.avatar),
                Image.asset('assets/courses/photo_ellipse.png', scale: 4)
              ]),
              SizedBox(height: 15),
              Text(coach == null ? widget.audio.userName : coach.getFullName(),
                  textAlign: TextAlign.center, style: OlukoFonts.olukoSuperBigFont(customFontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: Text(OlukoLocalizations.get(context, 'sentMessage'),
                      textAlign: TextAlign.center,
                      style: OlukoFonts.olukoBigFont(customFontWeight: FontWeight.w400, customColor: OlukoColors.grayColor))),
              SizedBox(height: 35),
              audioSlider(),
              SizedBox(height: 30),
              playButton(),
            ])),
            Align(
                alignment: Alignment.topRight,
                child: IconButton(icon: Icon(Icons.close, color: OlukoColors.primary), onPressed: () => widget.panelController.close()))
          ])),
    );
  }

  Widget playButton() {
    return GestureDetector(
        onTap: () async {
          _onPlay(url: widget.audio.url);
        },
        child: OlukoNeumorphism.isNeumorphismDesign
            ? Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Stack(alignment: Alignment.center, children: [
                  Image.asset(
                    'assets/neumorphic/green_ellipse.png',
                    scale: 4,
                  ),
                  _isPlaying
                      ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Image.asset(
                            'assets/neumorphic/pause_line.png',
                            scale: 3,
                          ),
                          SizedBox(width: 2),
                          Image.asset(
                            'assets/neumorphic/pause_line.png',
                            scale: 3,
                          )
                        ])
                      : Image.asset(
                          'assets/neumorphic/play.png',
                          scale: 3.5,
                        ),
                ]),
              )
            : Stack(alignment: Alignment.center, children: [
                Image.asset(
                  'assets/courses/green_circle.png',
                  scale: 5.5,
                ),
                Icon(_isPlaying ? Icons.pause : Icons.play_arrow, size: 26, color: OlukoColors.black)
              ]));
  }

  Future<void> _onPlay({String url}) async {
    if (!_isPlaying) {
      if (playedOnce) {
        await widget.audioPlayer.resume();
      } else {
        await widget.audioPlayer.play(url, isLocal: false);
        setState(() {
          playedOnce = true;
        });
      }

      setState(() {
        _completedPercentage = 0.0;
        _isPlaying = true;
      });

      widget.audioPlayer.onPlayerCompletion.listen((_) {
        setState(() {
          _isPlaying = false;
          _completedPercentage = 0.0;
          playedOnce = false;
        });
      });
      widget.audioPlayer.onDurationChanged.listen((duration) {
        setState(() {
          _totalDuration = duration.inMicroseconds;
        });
      });

      widget.audioPlayer.onAudioPositionChanged.listen((duration) {
        setState(() {
          _currentDuration = duration.inMicroseconds;
          _completedPercentage = _currentDuration.toDouble() / _totalDuration.toDouble();
        });
      });
    } else {
      await widget.audioPlayer.pause();
      setState(() {
        _isPlaying = false;
      });
    }
  }
}
