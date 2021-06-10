import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class OlukoVideoPlayer extends StatefulWidget {
  final String videoUrl;

  OlukoVideoPlayer({this.videoUrl, Key key}) : super(key: key);

  @override
  _OlukoVideoPlayerState createState() => _OlukoVideoPlayerState();
}

class _OlukoVideoPlayerState extends State<OlukoVideoPlayer> {
  VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(
        'https://cdn.videvo.net/videvo_files/video/free/2018-09/small_watermarked/180419_Boxing_07_04_preview.webm')
      ..initialize().then((_) {
        setState(() {
          _controller.setLooping(true);
          _controller.play();
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.all(Radius.circular(20))),
      child: Center(
        child: Center(
          child: _controller.value.initialized
              ? AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                )
              : Container(),
        ),
      ),
    );
  }
}
