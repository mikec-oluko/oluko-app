import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_cupertino_controls.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_material_controls.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

class OlukoVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final double aspectRatio;
  final bool showControls;
  final bool autoPlay;
  final String filePath;
  final bool allowFullScreen;
  final bool isOlukoControls;
  final bool showOptions;
  final Function(ChewieController chewieController) whenInitialized;
  final Function() onVideoFinished;
  final Function() closeVideoPlayer;

  OlukoVideoPlayer({
    this.videoUrl =
        //TODO: update me harcoded test
        'https://oluko-mvt.s3.us-west-1.amazonaws.com/assessments/85b2f81c1fe74f9cb5e804c57db30137/85b2f81c1fe74f9cb5e804c57db30137_2.mp4',
    this.showControls = true,
    this.autoPlay = true,
    this.filePath,
    this.whenInitialized,
    this.onVideoFinished,
    this.aspectRatio,
    Key key,
    this.allowFullScreen = true,
    this.isOlukoControls = false,
    this.closeVideoPlayer,
    this.showOptions = false,
  }) : super(key: key);

  @override
  _OlukoVideoPlayerState createState() => _OlukoVideoPlayerState();
}

class _OlukoVideoPlayerState extends State<OlukoVideoPlayer> {
  VideoPlayerController _controller;
  ChewieController chewieController;
  bool isLoading = true;

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
    if (widget.onVideoFinished != null) {
      _controller.addListener(() {
        if (_controller.value.position == _controller.value.duration) {
          widget.onVideoFinished();
        }
      });
    }
    if (widget.closeVideoPlayer != null) {
      _controller.addListener(() {
        if (_controller.value.position == _controller.value.duration) {
          widget.closeVideoPlayer();
        }
      });
    }

    Widget controls;
    if (Platform.isAndroid) {
      OlukoNeumorphism.isNeumorphismDesign && widget.isOlukoControls
          ? controls = OlukoMaterialControls(showOptions: widget.showOptions)
          : controls = MaterialControls();
    } else if (Platform.isIOS) {
      //TODO:Change IOS controls
      OlukoNeumorphism.isNeumorphismDesign && widget.isOlukoControls
          ? controls = OlukoCupertinoControls()
          : controls = CupertinoControls(backgroundColor: Colors.grey[200].withOpacity(0.3), iconColor:OlukoColors.black);
    }
    if (_controller != null) {
      _controller.initialize().then((value) {
        chewieController = ChewieController(
          allowFullScreen: widget.allowFullScreen,
          aspectRatio: widget.aspectRatio,
          customControls: controls,
          videoPlayerController: _controller,
          autoPlay: widget.autoPlay,
          showControls: widget.showControls,
          placeholder: Center(child: CircularProgressIndicator()),
          deviceOrientationsAfterFullScreen: [DeviceOrientation.portraitUp],
          deviceOrientationsOnEnterFullScreen: [
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight
          ],
          cupertinoProgressColors: ChewieProgressColors(
            handleColor: OlukoColors.black,
            backgroundColor: OlukoColors.black,
            bufferedColor: OlukoColors.black,
            playedColor: OlukoColors.black,
          ),
          materialProgressColors: ChewieProgressColors(
            handleColor: OlukoColors.black,
            backgroundColor: OlukoColors.black,
            bufferedColor: OlukoColors.black,
            playedColor: OlukoColors.black,
          ),
        );
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
        : const SizedBox();
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
