import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class OlukoVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final bool showControls;
  final bool autoPlay;
  final Function(ChewieController chewieController) whenInitialized;

  OlukoVideoPlayer(
      {this.videoUrl =
          //TODO: update me harcoded
          'https://oluko-mvt.s3.us-west-1.amazonaws.com/assessments/85b2f81c1fe74f9cb5e804c57db30137/85b2f81c1fe74f9cb5e804c57db30137_2.mp4',
      this.showControls = true,
      this.autoPlay = true,
      this.whenInitialized,
      Key key})
      : super(key: key);

  @override
  _OlukoVideoPlayerState createState() => _OlukoVideoPlayerState();
}

class _OlukoVideoPlayerState extends State<OlukoVideoPlayer> {
  VideoPlayerController _controller;
  ChewieController chewieController;
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((value) {
        chewieController = ChewieController(
            videoPlayerController: _controller,
            autoPlay: widget.autoPlay,
            showControls: widget.showControls,
            materialProgressColors: ChewieProgressColors(
                handleColor: Colors.black,
                backgroundColor: Colors.black,
                bufferedColor: Colors.black,
                playedColor: Colors.black));
        if (widget.whenInitialized != null) {
          widget.whenInitialized(chewieController);
        }
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return chewieController != null
        ? Chewie(
            controller: chewieController,
          )
        : SizedBox();
  }

  @override
  void dispose() {
    _controller.dispose();
    chewieController.dispose();
    super.dispose();
  }
}
