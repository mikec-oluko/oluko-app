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
  VideoEncoded({this.encodedFilesDir});
}

class Failure extends VideoState {
  final Exception exception;

  Failure({this.exception});
}

class VideoBloc extends Cubit<VideoState> {
  VideoBloc() : super(Loading());

  double _unitOfProgress = 0.19;
  String _processPhase = '';
  double _progress = 0.0;

  Future<void> createVideo(BuildContext context, File videoFile,
      double aspectRatio, String id) async {
    Video video;

    video = await _processVideo(context, videoFile, aspectRatio, id);

    emit(VideoSuccess(video: video));
  }

  Future<Video> _processVideo(BuildContext context, File videoFile,
      double aspectRatio, String id) async {
    _processPhase = "";
    _progress = 0.0;
    emit(VideoProcessing(processPhase: _processPhase, progress: _progress));

    final videoName = id;
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

    _processPhase = OlukoLocalizations.of(context).find('generatingThumbnail');
    _progress += _unitOfProgress;
    emit(VideoProcessing(processPhase: _processPhase, progress: _progress));

    final thumbFilePath = await EncodingProvider.getThumb(videoPath, 100, 150);

    _processPhase = OlukoLocalizations.of(context).find('encodingVideo');
    _progress += _unitOfProgress;
    emit(VideoProcessing(processPhase: _processPhase, progress: _progress));

    final encodedFilesDir =
        await EncodingProvider.encodeHLS(videoPath, outDirPath);
    emit(VideoEncoded(encodedFilesDir: encodedFilesDir));

    _processPhase = OlukoLocalizations.of(context).find('uploadingThumbnail');
    _progress += _unitOfProgress;
    emit(VideoProcessing(processPhase: _processPhase, progress: _progress));

    final thumbUrl = await VideoProcess.uploadFile(thumbFilePath, videoName);
    final videoUrl = await _uploadHLSFiles(context, encodedFilesDir, videoName);

    final video = Video(
      url: videoUrl,
      thumbUrl: thumbUrl,
      aspectRatio: aspectRatio,
      name: videoName,
      duration: durationInMilliseconds,
    );
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
