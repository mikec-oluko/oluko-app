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
      Video video = await _processVideo(context, videoFile, aspectRatio, id);
      emit(VideoSuccess(video: video));
    } catch (e) {
      emit(VideoFailure(exceptionMessage: e.toString()));
    }
  }

  Future<Video> _processVideo(BuildContext context, File videoFile,
      double aspectRatio, String id) async {
    String videoName = id;

    Video video = Video(name: videoName, aspectRatio: aspectRatio);

    _processPhase = "";
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

    _processPhase = OlukoLocalizations.of(context).find('generatingThumbnail');
    _progress += _unitOfProgress;
    emit(VideoProcessing(processPhase: _processPhase, progress: _progress));

    final thumbFilePath = await EncodingProvider.getThumb(videoPath, 100, 150);

    _processPhase = OlukoLocalizations.of(context).find('encodingVideo');
    _progress += _unitOfProgress;
    emit(VideoProcessing(processPhase: _processPhase, progress: _progress));

    final encodedFilesDir =
        await EncodingProvider.encodeHLS(videoPath, outDirPath);
    emit(VideoEncoded(
        encodedFilesDir: encodedFilesDir,
        video: video,
        thumbFilePath: thumbFilePath));

    _processPhase = OlukoLocalizations.of(context).find('uploadingThumbnail');
    _progress += _unitOfProgress;
    emit(VideoProcessing(processPhase: _processPhase, progress: _progress));

    video = await afterEcondingProcessing(
        video, thumbFilePath, encodedFilesDir, context);

    return video;
  }

  Future<Video> afterEcondingProcessing(Video video, String thumbFilePath,
      String encodedFilesDir, BuildContext context) async {
    final thumbUrl = await VideoProcess.uploadFile(thumbFilePath, video.name);
    final videoUrl =
        await _uploadHLSFiles(context, encodedFilesDir, video.name);

    video.url = videoUrl;
    video.thumbUrl = thumbUrl;

    return video;
  }

  Future<String> _uploadHLSFiles(
      BuildContext context, String dirPath, String videoName) async {
    final videosDir = Directory(dirPath);

    var playlistUrl = '';

    final files = videosDir.listSync();
    int i = 1;
    for (FileSystemEntity file in files) {
      final fileName = p.basename(file.path);
      final fileExtension = FileProcessing.getFileExtension(fileName);
      if (fileExtension == EnumToString.convertToString(FileExtension.m3u8))
        VideoProcess.updatePlaylistUrls(file, videoName, s3Storage: true);

      double fileProgress = 0.4 / files.length.toDouble();
      _processPhase =
          OlukoLocalizations.of(context).find('uploadingVideoFile') +
              i.toString() +
              OlukoLocalizations.of(context).find('outOf') +
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
}
