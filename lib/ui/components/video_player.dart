import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/video_player_helper.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_cupertino_controls.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_material_controls.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock/wakelock.dart';
import 'dart:io';

class OlukoVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String filePath;
  final double aspectRatio;
  final bool showControls;
  final bool autoPlay;
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
  final _placeHolder = const Center(child: CircularProgressIndicator());

  @override
  void initState() {
    super.initState();
    Wakelock.enable();
    _controller = buildControllerBySource(file: widget.filePath, url: widget.videoUrl)
      ..initialize().then((_) {
        chewieController = _buildChewieController();
      })
      ..addListener(() {
        if ((_controller.value.isBuffering || _controller.value.buffered.isNotEmpty) && _controller.value.duration != Duration.zero) {
          if (widget.onVideoFinished != null) {
            if (_controller.value.position == _controller.value.duration) {
              widget.onVideoFinished();
            }
          }
          if (widget.closeVideoPlayer != null) {
            if (_controller.value.position == _controller.value.duration) {
              widget.closeVideoPlayer();
            }
          }
        }
        if (widget.whenInitialized != null) {
          widget.whenInitialized(chewieController);
        }
        setState(() {});
      });
  }

  ChewieController _buildChewieController() {
    return ChewieController(
        videoPlayerController: _controller,
        allowFullScreen: widget.allowFullScreen,
        aspectRatio: widget.aspectRatio ?? _controller.value.aspectRatio,
        customControls: getOlukoControls(),
        autoPlay: widget.autoPlay,
        autoInitialize: true,
        showControls: widget.showControls,
        deviceOrientationsAfterFullScreen: [DeviceOrientation.portraitUp],
        deviceOrientationsOnEnterFullScreen: VideoPlayerHelper.fullScreenOptions,
        placeholder: _placeHolder,
        cupertinoProgressColors: VideoPlayerHelper.chewieProgressColors,
        materialProgressColors: VideoPlayerHelper.chewieProgressColors,
        errorBuilder: (context, text) => Center(
              child: Text(
                text,
                style: OlukoFonts.olukoTitleFont(customFontWeight: FontWeight.bold),
              ),
            ));
  }

  VideoPlayerController buildControllerBySource({@required String file, @required String url}) {
    if (widget.filePath != null) {
      return VideoPlayerHelper.VideoPlayerControllerFromFile(File(widget.filePath));
    } else {
      if (widget.videoUrl != null) {
        return VideoPlayerHelper.VideoPlayerControllerFromNetwork(widget.videoUrl);
      } else {
        return null;
      }
    }
  }

  Widget getOlukoControls() {
    Widget controls;
    if (Platform.isAndroid) {
      OlukoNeumorphism.isNeumorphismDesign && widget.isOlukoControls
          ? controls = OlukoMaterialControls(showOptions: widget.showOptions)
          : controls = const MaterialControls();
    } else if (Platform.isIOS) {
      //TODO:Change IOS controls
      OlukoNeumorphism.isNeumorphismDesign && widget.isOlukoControls
          ? controls = OlukoCupertinoControls(showOptions: widget.showOptions)
          : controls = CupertinoControls(backgroundColor: Colors.grey[200].withOpacity(0.3), iconColor: Colors.black);
    }
    return controls;
  }

  @override
  Widget build(BuildContext context) {
    return chewieController != null
        ? Chewie(
            controller: chewieController,
          )
        : const SizedBox.shrink();
  }

  @override
  void dispose() {
    Wakelock.disable();
    if (_controller != null) {
      _controller.dispose();
    }
    if (chewieController != null) {
      chewieController.dispose();
    }
    super.dispose();
  }
}
