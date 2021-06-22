import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/helpers/encoding_provider.dart';
import 'package:oluko_app/helpers/s3_provider.dart';
import 'package:oluko_app/models/task_submission.dart';
import 'package:oluko_app/models/video.dart';
import 'package:oluko_app/repositories/task_submission_repository.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

abstract class VideoState {}

class Loading extends VideoState {}

class VideoSuccess extends VideoState {
  Video video;
  VideoSuccess({this.video});
}

class VideoProcessingSuccess extends VideoState {
  final String processPhase;
  final double progress;
  VideoProcessingSuccess({this.processPhase, this.progress});
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

  Future<void> createVideo(File videoFile, double aspectRatio) async {
    Video video;

    video = await _processVideo(videoFile, aspectRatio);

    emit(VideoSuccess(video: video));
  }

  Future<Video> _processVideo(File videoFile, double aspectRatio) async {
    _progress = 0.0;
    emit(VideoProcessingSuccess(
        processPhase: _processPhase, progress: _progress));

    final String rand = '${new Random().nextInt(10000)}';
    final videoName = 'video$rand';
    final Directory extDir = await getApplicationDocumentsDirectory();
    final outDirPath = '${extDir.path}/Videos/$videoName';
    final videosDir = new Directory(outDirPath);
    videosDir.createSync(recursive: true);

    final videoPath = videoFile.path;
    final info = await EncodingProvider.getMediaInformation(videoPath);

    double durationInSeconds =
        EncodingProvider.getDuration(info.getMediaProperties());
    int durationInMilliseconds = (durationInSeconds * 1000).toInt();

    _processPhase = 'Generating thumbnail';
    _progress += _unitOfProgress;
    emit(VideoProcessingSuccess(
        processPhase: _processPhase, progress: _progress));

    final thumbFilePath = await EncodingProvider.getThumb(videoPath, 100, 150);

    _processPhase = 'Encoding video';
    _progress += _unitOfProgress;
    emit(VideoProcessingSuccess(
        processPhase: _processPhase, progress: _progress));

    final encodedFilesDir =
        await EncodingProvider.encodeHLS(videoPath, outDirPath);

    _processPhase = 'Uploading thumbnail to cloud storage';
    _progress += _unitOfProgress;
    emit(VideoProcessingSuccess(
        processPhase: _processPhase, progress: _progress));

    final thumbUrl = await _uploadFile(thumbFilePath, videoName);
    final videoUrl = await _uploadHLSFiles(encodedFilesDir, videoName);

    final video = Video(
      url: videoUrl,
      thumbUrl: thumbUrl,
      aspectRatio: aspectRatio,
      name: videoName,
      duration: durationInMilliseconds,
    );
    return video;
  }

  Future<String> _uploadHLSFiles(dirPath, videoName) async {
    final videosDir = Directory(dirPath);

    var playlistUrl = '';

    final files = videosDir.listSync();
    int i = 1;
    for (FileSystemEntity file in files) {
      final fileName = p.basename(file.path);
      final fileExtension = getFileExtension(fileName);
      if (fileExtension == 'm3u8')
        _updatePlaylistUrls(file, videoName, s3Storage: true);

      double fileProgress = 0.4 / files.length.toDouble();
      _processPhase = 'Uploading video part file $i out of ${files.length}';
      _progress += fileProgress;
      emit(VideoProcessingSuccess(
          processPhase: _processPhase, progress: _progress));

      final downloadUrl = await _uploadFile(file.path, videoName);

      if (fileName == 'master.m3u8') {
        playlistUrl = downloadUrl;
      }
      i++;
    }

    return playlistUrl;
  }

  String getFileExtension(String fileName) {
    final exploded = fileName.split('.');
    return exploded[exploded.length - 1];
  }

  Future<String> _uploadFile(filePath, folderName) async {
    final file = new File(filePath);
    final basename = p.basename(filePath);

    final S3Provider s3Provider = S3Provider();
    String downloadUrl =
        await s3Provider.putFile(file.readAsBytesSync(), folderName, basename);

    return downloadUrl;
  }

  void _updatePlaylistUrls(File file, String videoName, {bool s3Storage}) {
    final lines = file.readAsLinesSync();
    var updatedLines = [];

    for (final String line in lines) {
      var updatedLine = line;
      if (line.contains('.ts') || line.contains('.m3u8')) {
        updatedLine = s3Storage == null
            ? '$videoName%2F$line?alt=media'
            : '$line?alt=media';
      }
      updatedLines.add(updatedLine);
    }
    final updatedContents =
        updatedLines.reduce((value, element) => value + '\n' + element);

    file.writeAsStringSync(updatedContents);
  }
}
