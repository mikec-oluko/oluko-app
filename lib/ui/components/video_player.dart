import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oluko_app/utils/chewieMaterialControls/oluko_material_controls.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

class OlukoVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final bool showControls;
  final bool autoPlay;
  final String filePath;
  final Function(ChewieController chewieController) whenInitialized;

  OlukoVideoPlayer(
      {this.videoUrl =
          //TODO: update me harcoded test
          'https://oluko-mvt.s3.us-west-1.amazonaws.com/assessments/85b2f81c1fe74f9cb5e804c57db30137/85b2f81c1fe74f9cb5e804c57db30137_2.mp4',
      this.showControls = true,
      this.autoPlay = true,
      this.filePath,
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
    if (widget.filePath != null) {
      _controller = VideoPlayerController.file(File(widget.filePath));
    } else {
      if (widget.videoUrl != null) {
        _controller = VideoPlayerController.network(widget.videoUrl);
      } else {
        _controller = null;
      }
    }
    Widget controls;
    if (Platform.isAndroid) {
      controls = OlukoMaterialControls();
    } else if (Platform.isIOS) {
      controls = CupertinoControls(backgroundColor: Colors.grey[100].withOpacity(0.2), iconColor: Colors.black);
    }
    if (_controller != null) {
      _controller
        ..initialize().then((value) {
          chewieController = ChewieController(
              customControls: controls,
              videoPlayerController: _controller,
              autoPlay: widget.autoPlay,
              showControls: widget.showControls,
              placeholder: Center(child: CircularProgressIndicator()),
              deviceOrientationsAfterFullScreen: [DeviceOrientation.portraitUp],
              cupertinoProgressColors: ChewieProgressColors(
                  handleColor: Colors.black,
                  backgroundColor: Colors.black,
                  bufferedColor: Colors.black,
                  playedColor: Colors.black),
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
    if (_controller != null) {
      _controller.dispose();
    }
    if (chewieController != null) {
      chewieController.dispose();
    }
    super.dispose();
  }
}
