import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/submodels/audio.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/ui/components/stories_item.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class AudioDialogContent extends StatefulWidget {
  final UserResponse coach;
  final Audio audio;

  AudioDialogContent({this.coach, this.audio});

  @override
  _State createState() => _State();
}

class _State extends State<AudioDialogContent> {
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
    //audioPlayer.setReleaseMode(ReleaseMode.STOP);
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
      width: 250,
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
    return audioDialogContent(context, widget.coach);
  }

  Widget audioDialogContent(BuildContext context, UserResponse coach) {
    return Container(
        decoration: BoxDecoration(
            image: DecorationImage(
          image: AssetImage("assets/courses/dialog_background.png"),
          fit: BoxFit.cover,
        )),
        child: Stack(children: [
          Center(
              child: Column(children: [
            SizedBox(height: 30),
            Stack(alignment: Alignment.center, children: [
              StoriesItem(maxRadius: 65, imageUrl: coach.avatar),
              Image.asset('assets/courses/photo_ellipse.png', scale: 4)
            ]),
            SizedBox(height: 15),
            Text(coach.firstName + ' ' + coach.lastName,
                textAlign: TextAlign.center,
                style: OlukoFonts.olukoSuperBigFont(
                    custoFontWeight: FontWeight.bold)),
            SizedBox(height: 15),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: Text(OlukoLocalizations.get(context, 'hasMessage'),
                    textAlign: TextAlign.center,
                    style: OlukoFonts.olukoBigFont(
                        custoFontWeight: FontWeight.w300))),
            SizedBox(height: 10),
            audioSlider(),
            SizedBox(height: 5),
            GestureDetector(
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
                    scale: 4.5,
                  ),
                  Icon(isPlaying ? Icons.pause : Icons.play_arrow,
                      size: 32, color: OlukoColors.black)
                ])),
          ])),
          Align(
              alignment: Alignment.topRight,
              child: IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context)))
        ]));
  }
}
