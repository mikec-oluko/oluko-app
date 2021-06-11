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
          'https://cdn.videvo.net/videvo_files/video/free/2018-09/small_watermarked/180419_Boxing_07_04_preview.webm',
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
    _controller = VideoPlayerController.network(
        'https://cdn.videvo.net/videvo_files/video/free/2018-09/small_watermarked/180419_Boxing_07_04_preview.webm')
      ..initialize().then((value) {
        _chewieController = ChewieController(
            videoPlayerController: _controller,
            autoPlay: true,
            looping: true,
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
