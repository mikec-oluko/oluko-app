import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/services.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerHelper {
  static final videoPlayerOptions = VideoPlayerOptions(mixWithOthers: true);
  static final fullScreenOptions = [
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight
  ];

  static final chewieProgressColors = ChewieProgressColors(
    handleColor: OlukoColors.black,
    backgroundColor: OlukoColors.black,
    bufferedColor: OlukoColors.black,
    playedColor: OlukoColors.black,
  );

  static VideoPlayerController VideoPlayerControllerFromFile(File file) {
    assert(file != null);
    return VideoPlayerController.file(file, videoPlayerOptions: VideoPlayerHelper.videoPlayerOptions);
  }

  static VideoPlayerController VideoPlayerControllerFromNetwork(String url) {
    assert(url != null);
    return VideoPlayerController.network(url, videoPlayerOptions: VideoPlayerHelper.videoPlayerOptions);
  }
}
