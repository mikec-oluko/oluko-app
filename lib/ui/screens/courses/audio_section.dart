import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/submodels/audio.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/ui/components/stories_item.dart';

class AudioSection extends StatefulWidget {
  final UserResponse coach;
  final Audio audio;
  final bool showTopDivider;

  AudioSection({this.coach, this.audio, this.showTopDivider = true});

  @override
  _State createState() => _State();
}

class _State extends State<AudioSection> {
  AudioPlayer audioPlayer;
  Duration _duration = new Duration();
  Duration _position = new Duration();
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    initPlayer();
  }

  void seekToSeconds(int second) {
    Duration newDuration = Duration(seconds: second);
    audioPlayer.seek(newDuration);
  }

  void initPlayer() {
    audioPlayer = new AudioPlayer();
    audioPlayer.setUrl(widget.audio.url);
    audioPlayer.onDurationChanged.listen((Duration d) {
      print('Max duration: $d');
      setState(() => _duration = d);
    });
    audioPlayer.onAudioPositionChanged.listen((Duration p) {
      print('Current position: $p');
      setState(() => _position = p);
    });
  }

  Widget audioSlider() {
    return Container(
      width: 150,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Slider(
            activeColor: OlukoColors.primary,
            inactiveColor: Colors.grey,
            value: _position.inSeconds.toDouble(),
            max: _duration.inSeconds.toDouble(),
            onChanged: (double value) {
              setState(() {
                seekToSeconds(value.toInt());
                value = value;
              });
            },
          ),
        ],
      ),
    );
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
              _imageItem(context, widget.coach.avatar, widget.coach.firstName),
              playButton(),
              audioSlider(),
              Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: Image.asset(
                    'assets/courses/audio_horizontal_vector.png',
                    scale: 3.5,
                  )),
              Image.asset(
                'assets/courses/bin.png',
                scale: 16,
              )
            ])
          ],
        ),
      ),
    );
  }

  Widget playButton() {
    return GestureDetector(
        onTap: () {
          if (isPlaying == false) {
            audioPlayer.resume();
            setState(() {
              isPlaying = true;
            });
          } else {
            audioPlayer.pause();
            setState(() {
              isPlaying = false;
            });
          }
        },
        child: Stack(alignment: Alignment.center, children: [
          Image.asset(
            'assets/courses/green_circle.png',
            scale: 5.5,
          ),
          Icon(isPlaying ? Icons.pause : Icons.play_arrow,
              size: 26, color: OlukoColors.black)
        ]));
  }

  Widget _imageItem(BuildContext context, String imageUrl, String name) {
    return Container(
        width: 85,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            StoriesItem(maxRadius: 28, imageUrl: imageUrl),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                name,
                textAlign: TextAlign.center,
                style: OlukoFonts.olukoSmallFont(
                    customColor: OlukoColors.grayColor),
              ),
            )
          ],
        ));
  }
}
