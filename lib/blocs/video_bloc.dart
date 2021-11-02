import 'dart:io';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/helpers/encoding_provider.dart';
import 'package:oluko_app/models/enums/file_extension_enum.dart';
import 'package:oluko_app/models/submodels/video.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/file_processing.dart';
import 'package:oluko_app/utils/time_converter.dart';
import 'package:oluko_app/utils/video_process.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:global_configuration/global_configuration.dart';

abstract class VideoState {}

class Loading extends VideoState {}

class VideoSuccess extends VideoState {
  Video video;
  VideoSuccess({this.video});
}

class VideoProcessing extends VideoState {
  final String processPhase;
  final double progress;
  VideoProcessing({this.processPhase, this.progress});
}

class VideoEncoded extends VideoState {
  final String encodedFilesDir;
  final Video video;
  final String thumbFilePath;
  VideoEncoded({this.encodedFilesDir, this.video, this.thumbFilePath});
}

class VideoFailure extends VideoState {
  final String exceptionMessage;

  VideoFailure({this.exceptionMessage});
}

class VideoBloc extends Cubit<VideoState> {
  VideoBloc() : super(Loading());

  double _unitOfProgress = 0.19;
  String _processPhase = '';
  double _progress = 0.0;

  Future<void> createVideo(BuildContext context, File videoFile,
      double aspectRatio, String id) async {
    try {
      Video video;
      if (GlobalConfiguration().getValue('encodeOnDevice') == 'true') {
        video = await _processVideo(context, videoFile, aspectRatio, id);
      } else {
        //video = await _processVideoWithoutEncoding(context, videoFile, aspectRatio, id);
        video =
            await _processVideo264Encoding(context, videoFile, aspectRatio, id);
      }
      emit(VideoSuccess(video: video));
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      emit(VideoFailure(exceptionMessage: e.toString()));
      rethrow;
    }
  }

  Future<Video> _processVideo(BuildContext context, File videoFile,
      double aspectRatio, String id) async {
    String videoName = id;

    Video video = Video(name: videoName, aspectRatio: aspectRatio);

    _processPhase = '';
    _progress = 0.0;
    emit(VideoProcessing(processPhase: _processPhase, progress: _progress));

    final Directory extDir = await getApplicationDocumentsDirectory();
    final outDirPath = '${extDir.path}/Videos/$videoName';
    final videosDir = new Directory(outDirPath);
    videosDir.createSync(recursive: true);
    final videoPath = videoFile.path;
    final info = await EncodingProvider.getMediaInformation(videoPath);
    double durationInSeconds =
        EncodingProvider.getDuration(info.getMediaProperties());
    int durationInMilliseconds =
        TimeConverter.fromSecondsToMilliSeconds(durationInSeconds).toInt();

    video.duration = durationInMilliseconds;

    _processPhase = OlukoLocalizations.get(context, 'generatingThumbnail');
    _progress += _unitOfProgress;
    emit(VideoProcessing(processPhase: _processPhase, progress: _progress));
    String thumbFilePath;
    try {
      thumbFilePath = await EncodingProvider.getThumb(videoPath, 100, 150);
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      rethrow;
    }

    _processPhase = OlukoLocalizations.get(context, 'encodingVideo');
    _progress += _unitOfProgress;
    emit(VideoProcessing(processPhase: _processPhase, progress: _progress));

    // final encodedFilesDir = await EncodingProvider.encodeHLS(videoPath, outDirPath);
    // emit(VideoEncoded(encodedFilesDir: encodedFilesDir, video: video, thumbFilePath: thumbFilePath));

    _processPhase = OlukoLocalizations.get(context, 'uploadingThumbnail');
    _progress += _unitOfProgress;
    emit(VideoProcessing(processPhase: _processPhase, progress: _progress));

    video = await uploadVideo(video, thumbFilePath, videoPath, context);

    return video;
  }

  Future<Video> uploadVideo(Video video, String thumbFilePath,
      String encodedFilesDir, BuildContext context) async {
    String thumbUrl;
    if (thumbFilePath != null) {
      thumbUrl = await VideoProcess.uploadFile(thumbFilePath, video.name);
    }
    final videoUrl = await _uploadFiles(context, encodedFilesDir, video.name);

    video.url = videoUrl;
    video.thumbUrl = thumbUrl;

    return video;
  }

  Future<Video> uploadVideoWithoutProcessing(Video video, String thumbFilePath,
      String filePath, BuildContext context) async {
    String thumbUrl;
    if (thumbFilePath != null) {
      thumbUrl = await VideoProcess.uploadFile(thumbFilePath, video.name);
    }

    emit(VideoProcessing(
        processPhase: OlukoLocalizations.get(context, 'uploadingVideoFile'),
        progress: 0));
    final videoUrl = await VideoProcess.uploadFile(filePath, video.name);
    emit(VideoProcessing(processPhase: _processPhase, progress: _progress));

    video.url = videoUrl;
    video.thumbUrl = thumbUrl;

    return video;
  }

  Future<String> _uploadFiles(
      BuildContext context, String dirPath, String videoName) async {
    final videosDir = Directory(dirPath);

    var playlistUrl = '';

    final files = videosDir.listSync();
    int i = 1;
    for (FileSystemEntity file in files) {
      final fileName = p.basename(file.path);
      final fileExtension = FileProcessing.getFileExtension(fileName);
      if (fileExtension == EnumToString.convertToString(FileExtension.m3u8)) {
        if (file is File) {
          VideoProcess.updatePlaylistUrls(file, videoName, s3Storage: true);
        }
      }

      double fileProgress = 0.4 / files.length.toDouble();
      _processPhase = OlukoLocalizations.get(context, 'uploadingVideoFile') +
          i.toString() +
          OlukoLocalizations.get(context, 'outOf') +
          files.length.toString();
      _progress += fileProgress;
      emit(VideoProcessing(processPhase: _processPhase, progress: _progress));

      final downloadUrl = await VideoProcess.uploadFile(file.path, videoName);

      if (fileName == 'master.m3u8') {
        playlistUrl = downloadUrl;
      }
      i++;
    }

    return playlistUrl;
  }

  Future<Video> _processVideoWithoutEncoding(BuildContext context,
      File videoFile, double aspectRatio, String id) async {
    String videoName = id;

    Video video = Video(name: videoName, aspectRatio: aspectRatio);

    _processPhase = '';
    _progress = 0.0;
    emit(VideoProcessing(processPhase: _processPhase, progress: _progress));

    final Directory extDir = await getApplicationDocumentsDirectory();
    final outDirPath = '${extDir.path}/Videos/$videoName';
    final videosDir = new Directory(outDirPath);
    videosDir.createSync(recursive: true);
    final videoPath = videoFile.path;
    final info = await EncodingProvider.getMediaInformation(videoPath);
    double durationInSeconds =
        EncodingProvider.getDuration(info.getMediaProperties());
    int durationInMilliseconds =
        TimeConverter.fromSecondsToMilliSeconds(durationInSeconds).toInt();

    video.duration = durationInMilliseconds;

    _processPhase = OlukoLocalizations.get(context, 'generatingThumbnail');
    _progress += _unitOfProgress;
    emit(VideoProcessing(processPhase: _processPhase, progress: _progress));
    String thumbFilePath = null;
    try {
      thumbFilePath = await EncodingProvider.getThumb(videoPath, 100, 150);
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      // rethrow;
    }

    _processPhase = OlukoLocalizations.get(context, 'uploadingThumbnail');
    _progress += _unitOfProgress;
    emit(VideoProcessing(processPhase: _processPhase, progress: _progress));

    video = await uploadVideoWithoutProcessing(
        video, thumbFilePath, videoPath, context);

    return video;
  }

  Future<Video> _processVideo264Encoding(BuildContext context, File videoFile,
      double aspectRatio, String id) async {
    String videoName = id;

    Video video = Video(name: videoName, aspectRatio: aspectRatio);

    _processPhase = '';
    _progress = 0.0;
    emit(VideoProcessing(processPhase: _processPhase, progress: _progress));

    final Directory extDir = await getApplicationDocumentsDirectory();
    final outDirPath = '${extDir.path}/Videos/$videoName';
    final videosDir = new Directory(outDirPath);
    videosDir.createSync(recursive: true);

    final videoPath = videoFile.path;
    final info = await EncodingProvider.getMediaInformation(videoPath);
    double durationInSeconds =
        EncodingProvider.getDuration(info.getMediaProperties());
    int durationInMilliseconds =
        TimeConverter.fromSecondsToMilliSeconds(durationInSeconds).toInt();

    video.duration = durationInMilliseconds;

    _processPhase = OlukoLocalizations.get(context, 'generatingThumbnail');
    _progress += _unitOfProgress;
    emit(VideoProcessing(processPhase: _processPhase, progress: _progress));
    String thumbFilePath = null;
    try {
      thumbFilePath = await EncodingProvider.getThumb(videoPath, 100, 150);
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      // rethrow;
    }
    _processPhase = OlukoLocalizations.get(context, 'uploadingThumbnail');
    _progress += _unitOfProgress;
    emit(VideoProcessing(processPhase: _processPhase, progress: _progress));
    final encodedFile = await EncodingProvider.encode264(videoPath, outDirPath);
    if (videosDir.exists() != null) {
      video = await uploadVideoWithoutProcessing(
          video, thumbFilePath, encodedFile, context);
    }

    return video;
  }
}
