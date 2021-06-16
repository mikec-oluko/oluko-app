import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oluko_app/ui/screens/videos/aspect_ratio.dart';
import 'package:oluko_app/ui/screens/videos/player_life_cycle.dart';
import 'package:oluko_app/ui/screens/videos/video_play_pause.dart';
import 'package:video_player/video_player.dart';

class OlukoVideoPlayer extends StatefulWidget {
  final String videoUrl;

  OlukoVideoPlayer(
      {this.videoUrl =
          //TODO: update me harcoded
          'https://oluko-mvt.s3.us-west-1.amazonaws.com/assessments/85b2f81c1fe74f9cb5e804c57db30137/85b2f81c1fe74f9cb5e804c57db30137.mov',
      Key key})
      : super(key: key);

  @override
  _OlukoVideoPlayerState createState() => _OlukoVideoPlayerState();
}

class _OlukoVideoPlayerState extends State<OlukoVideoPlayer> {
  VideoPlayerController _controller;
  ChewieController _chewieController;
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((value) {
        _chewieController = ChewieController(
            videoPlayerController: _controller,
            autoPlay: true,
            materialProgressColors: ChewieProgressColors(
                handleColor: Colors.black,
                backgroundColor: Colors.black,
                bufferedColor: Colors.black,
                playedColor: Colors.black));

        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: 200,
        child: _chewieController != null
            ? Chewie(
                controller: _chewieController,
              )
            : SizedBox());
  }
}
