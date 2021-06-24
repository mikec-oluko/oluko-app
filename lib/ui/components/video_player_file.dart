import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class OlukoVideoPlayerFile extends StatefulWidget {
  final bool showControls;
  final bool autoPlay;
  final String filePath;
  final Function(ChewieController chewieController) whenInitialized;

  OlukoVideoPlayerFile(
      {this.filePath,
      this.showControls = true,
      this.autoPlay = true,
      this.whenInitialized,
      Key key})
      : super(key: key);

  @override
  _OlukoVideoPlayerFileState createState() => _OlukoVideoPlayerFileState();
}

class _OlukoVideoPlayerFileState extends State<OlukoVideoPlayerFile> {
  VideoPlayerController _controller;
  ChewieController chewieController;
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.filePath))
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
