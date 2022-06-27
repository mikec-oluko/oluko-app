import 'dart:io';
import 'dart:isolate';

import 'package:flutter/widgets.dart';
import 'package:oluko_app/models/enrollment_audio.dart';
import 'package:oluko_app/models/submodels/audio.dart';
import 'package:oluko_app/models/submodels/class_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:path/path.dart' as path;

import '../helpers/video_player_helper.dart';
import '../helpers/video_thumbnail.dart';
import '../models/submodels/video.dart';
import '../utils/oluko_localizations.dart';
import '../utils/time_converter.dart';
import '../utils/video_process.dart';

class VideoService {
  static Future<Video> processVideoWithoutEncoding(
      String videoFilePath, double aspectRatio, String id, String directory, int duration, String thumbnailPath,
      [SendPort port]) async {
    try {
      String videoName = id;
      Video video = Video(name: videoName, aspectRatio: aspectRatio);
      var _processPhase = '';
      var _progress = 0.0;
      //emit(VideoProcessing(processPhase: _processPhase, progress: _progress));
      if (port != null) {
        port.send({'processPhase': _processPhase, 'progress': _progress});
      }
      //
      final Directory extDir = Directory(directory);
      final outDirPath = '${extDir.path}/Videos/$videoName';
      final videosDir = new Directory(outDirPath);
      videosDir.createSync(recursive: true);
      final videoPath = videoFilePath;
      // final info = await EncodingProvider.getMediaInformation(videoPath);
      File videoFile = File(videoPath);
      video.duration = duration;
      _processPhase = 'generatingThumbnail';
      // num _unitOfProgress;
      // _progress += _unitOfProgress;
      //emit(VideoProcessing(processPhase: _processPhase, progress: _progress));
      if (port != null) {
        port.send({'processPhase': _processPhase, 'progress': _progress});
      }
      //

      _processPhase = 'uploadingThumbnail';
      // _progress += _unitOfProgress;
      //emit(VideoProcessing(processPhase: _processPhase, progress: _progress));
      if (port != null) {
        port.send({'processPhase': _processPhase, 'progress': _progress});
      }
      //

      return video = await uploadVideoWithoutProcessing(video, thumbnailPath, videoPath, port);
    } catch (e) {
      print(e.toString());
      rethrow;
    }
  }

  static Future<Video> uploadVideoWithoutProcessing(Video video, String thumbFilePath, String filePath, SendPort port) async {
    String thumbUrl;
    if (thumbFilePath != null) {
      thumbUrl = await VideoProcess.uploadFile(thumbFilePath, video.name);
    }

    //emit(VideoProcessing(processPhase: OlukoLocalizations.get(context, 'uploadingVideoFile'), progress: 0));
    // port.send({'processPhase': 'uploadingVideoFile', 'progress': 0});
    //
    final videoUrl = await VideoProcess.uploadFile(filePath, video.name);
    //emit(VideoProcessing(processPhase: _processPhase, progress: _progress));
    // port.send({'processPhase': _processPhase, 'progress': _progress});
    //
    video.url = videoUrl;
    video.thumbUrl = thumbUrl;

    return video;
  }

  static Future<int> getVideoDuration(File videoFile) async {
    VideoPlayerController controller = VideoPlayerHelper.VideoPlayerControllerFromFile(videoFile);
    double durationInSeconds = 0;
    try {
      await controller.initialize();
    } catch (e) {
      print(e.toString());
      rethrow;
    }
    durationInSeconds = controller.value.duration.inSeconds.toDouble(); //EncodingProvider.getDuration(info.getMediaProperties());
    controller.dispose();
    int durationInMilliseconds = TimeConverter.fromSecondsToMilliSeconds(durationInSeconds).toInt();
    return durationInMilliseconds;
  }

  static Future<String> createVideoThumbnail(String videoPath) async {
    String thumbFilePath = null;
    try {
      final String outDirPath = path.dirname(videoPath);

      ThumbnailResult thumbnail = await genThumbnail(ThumbnailRequest(
        video: videoPath,
        maxWidth: 100,
        maxHeight: 150,
        thumbnailPath: outDirPath,
      ));

      thumbFilePath = thumbnail.path;
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
    return thumbFilePath;
  }
}
