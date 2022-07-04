import 'dart:io';

import 'package:video_player/video_player.dart';

class VideoPlayerHelper {
  static final videoPlayerOptions = VideoPlayerOptions(mixWithOthers: true);

  static VideoPlayerController VideoPlayerControllerFromFile(File file) {
    assert(file != null);
    return VideoPlayerController.file(file, videoPlayerOptions: VideoPlayerHelper.videoPlayerOptions);
  }

  static VideoPlayerController VideoPlayerControllerFromNetwork(String url) {
    assert(url != null);
    return VideoPlayerController.network(url, videoPlayerOptions: VideoPlayerHelper.videoPlayerOptions);
  }
}
