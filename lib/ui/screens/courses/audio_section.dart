import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/blocs/story_list_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/submodels/audio.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/ui/components/course_progress_bar.dart';
import 'package:oluko_app/ui/components/stories_item.dart';

class AudioSection extends StatefulWidget {
  final UserResponse coach;
  final Audio audio;
  final bool showTopDivider;
  final Function() onAudioPressed;

  AudioSection({this.coach, this.audio, this.showTopDivider = true, this.onAudioPressed});

  @override
  _State createState() => _State();
}

class _State extends State<AudioSection> {
  int _totalDuration;
  int _currentDuration;
  double _completedPercentage = 0.0;
  bool _isPlaying = false;
  AudioPlayer audioPlayer = AudioPlayer();
  bool playedOnce = false;

  Widget audioSlider() {
    return Container(
        width: 150, child: Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: CourseProgressBar(value: _completedPercentage)));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.showTopDivider
                ? Divider(
                    color: OlukoColors.grayColor,
                    height: 50,
                  )
                : SizedBox(),
            Row(children: [
              widget.coach == null
                  ? _imageItem(context, widget.audio.userAvatarThumbnail, widget.audio.userName)
                  : _imageItem(context, widget.coach.avatar, widget.coach.firstName),
              playButton(),
              audioSlider(),
              Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: Image.asset(
                    'assets/courses/audio_horizontal_vector.png',
                    scale: 3.5,
                  )),
              GestureDetector(
                  onTap: () => widget.onAudioPressed(),
                  child: Image.asset(
                    'assets/courses/bin.png',
                    scale: 16,
                  ))
            ])
          ],
        ),
      ),
    );
  }

  Widget playButton() {
    return GestureDetector(
        onTap: () async {
          _onPlay(url: widget.audio.url);
        },
        child: Stack(alignment: Alignment.center, children: [
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
        await audioPlayer.resume();
      } else {
        await audioPlayer.play(url, isLocal: false);
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

  Widget _imageItem(BuildContext context, String imageUrl, String name) {
    return Container(
        width: 85,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            StoriesItem(maxRadius: 28, imageUrl: imageUrl, bloc: StoryListBloc()),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                name,
                textAlign: TextAlign.center,
                style: OlukoFonts.olukoSmallFont(customColor: OlukoColors.grayColor),
              ),
            )
          ],
        ));
  }
}
