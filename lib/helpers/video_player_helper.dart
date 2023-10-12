import 'dart:io';
import 'dart:ui';
import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/services/global_service.dart';
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
    bufferedColor: OlukoColors.grayColor,
    playedColor: OlukoColors.black,
  );

  static VideoPlayerController videoPlayerControllerFromFile(File file) {
    assert(file != null);
    return VideoPlayerController.file(file, videoPlayerOptions: VideoPlayerHelper.videoPlayerOptions);
  }

  static VideoPlayerController videoPlayerControllerFromNetwork(String url) {
    assert(url != null);
    return VideoPlayerController.networkUrl(Uri.parse(url), videoPlayerOptions: VideoPlayerHelper.videoPlayerOptions);
  }

  static String getVideoFromSourceActive({@required String videoHlsUrl, @required String videoUrl}) {
    return GlobalService().appUseVideoHls ? videoHlsUrl ?? videoUrl : videoUrl;
  }
}
