import 'package:flutter/material.dart';
import 'package:oluko_app/ui/screens/videos/fade_animation.dart';
import 'package:video_player/video_player.dart';

class VideoPlayPause extends StatefulWidget {
  VideoPlayPause(this.controller);

  final VideoPlayerController controller;

  @override
  State createState() {
    return _VideoPlayPauseState();
  }
}

class _VideoPlayPauseState extends State<VideoPlayPause> {
  _VideoPlayPauseState() {
    listener = () {
      if (mounted) {
        setState(() {});
      }
    };
  }

  FadeAnimation imageFadeAnim =
      FadeAnimation(child: const Icon(Icons.play_arrow, size: 100.0));
  VoidCallback listener;

  VideoPlayerController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    //controller.addListener(listener);
    controller.setVolume(1.0);
    //controller.play();
  }

  @override
  void deactivate() {
    controller.setVolume(0.0);
    controller.removeListener(listener);
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = <Widget>[
      GestureDetector(
        child: VideoPlayer(controller),
        onTap: () {
          // if (!controller.value.initialized) {
          //   return;
          // }
          // if (controller.value.isPlaying) {
          //   imageFadeAnim =
          //       FadeAnimation(child: const Icon(Icons.pause, size: 100.0));
          //   controller.pause();
          // } else {
          //   imageFadeAnim =
          //       FadeAnimation(child: const Icon(Icons.play_arrow, size: 100.0));
          //   controller.play();
          // }
        },
      ),
      /*Align(
        alignment: Alignment.bottomCenter,
        child: VideoProgressIndicator(
          controller,
          allowScrubbing: true,
        ),
      ),*/
      Center(child: imageFadeAnim),
      Center(
          child: controller.value.isBuffering
              ? const CircularProgressIndicator()
              : null),
    ];

    return Stack(
      fit: StackFit.passthrough,
      children: children,
    );
  }
}
