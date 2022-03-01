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

import '../helpers/video_thumbnail.dart';
import '../models/submodels/video.dart';
import '../utils/oluko_localizations.dart';
import '../utils/time_converter.dart';
import '../utils/video_process.dart';

class VideoService {
  static Future<Video> processVideoWithoutEncoding(File videoFile, double aspectRatio, String id, SendPort port) async {
    String videoName = id;
    Video video = Video(name: videoName, aspectRatio: aspectRatio);
    var _processPhase = '';
    var _progress = 0.0;
    //emit(VideoProcessing(processPhase: _processPhase, progress: _progress));
    port.send({'processPhase': _processPhase, 'progress': _progress});
    //
    final Directory extDir = await getApplicationDocumentsDirectory();
    final outDirPath = '${extDir.path}/Videos/$videoName';
    final videosDir = new Directory(outDirPath);
    videosDir.createSync(recursive: true);
    final videoPath = videoFile.path;
    // final info = await EncodingProvider.getMediaInformation(videoPath);
    VideoPlayerController controller = new VideoPlayerController.file(videoFile);
    double durationInSeconds = controller.value.duration.inSeconds.toDouble(); //EncodingProvider.getDuration(info.getMediaProperties());
    int durationInMilliseconds = TimeConverter.fromSecondsToMilliSeconds(durationInSeconds).toInt();
    video.duration = durationInMilliseconds;
    _processPhase = 'generatingThumbnail';
    num _unitOfProgress;
    _progress += _unitOfProgress;
    //emit(VideoProcessing(processPhase: _processPhase, progress: _progress));
    port.send({'processPhase': _processPhase, 'progress': _progress});
    //
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
      // rethrow;
    }

    _processPhase = 'uploadingThumbnail';
    _progress += _unitOfProgress;
    //emit(VideoProcessing(processPhase: _processPhase, progress: _progress));
    port.send({'processPhase': _processPhase, 'progress': _progress});
    //

    return video = await uploadVideoWithoutProcessing(video, thumbFilePath, videoPath, port);
  }

  static Future<Video> uploadVideoWithoutProcessing(Video video, String thumbFilePath, String filePath, SendPort port) async {
    String thumbUrl;
    if (thumbFilePath != null) {
      thumbUrl = await VideoProcess.uploadFile(thumbFilePath, video.name);
    }

    //emit(VideoProcessing(processPhase: OlukoLocalizations.get(context, 'uploadingVideoFile'), progress: 0));
    port.send({'processPhase': 'uploadingVideoFile', 'progress': 0});
    //
    final videoUrl = await VideoProcess.uploadFile(filePath, video.name);
    //emit(VideoProcessing(processPhase: _processPhase, progress: _progress));
    // port.send({'processPhase': _processPhase, 'progress': _progress});
    //
    video.url = videoUrl;
    video.thumbUrl = thumbUrl;

    return video;
  }
}
