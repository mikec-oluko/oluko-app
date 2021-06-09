import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oluko_app/helpers/encoding_provider.dart';
import 'package:oluko_app/helpers/s3_provider.dart';
import 'package:oluko_app/models/video.dart';
import 'package:oluko_app/repositories/video_repository.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

abstract class VideoState {
  final List<Video> videoList;
  const VideoState({this.videoList});
}

class Loading extends VideoState {}

class VideosSuccess extends VideoState {
  final List<Video> videos;

  const VideosSuccess({this.videos}) : super(videoList: videos);
}

class TakeVideoSuccess extends VideoState {
  final String processPhase;
  final double progress;
  final bool processing;
  const TakeVideoSuccess({this.processPhase, this.progress, this.processing});
}

class Failure extends VideoState {
  final Exception exception;

  Failure({this.exception});
}

class VideoBloc extends Cubit<VideoState> {
  VideoBloc() : super(Loading());

  List<Video> _videoList = [];
  bool _imagePickerActive = false;
  double _unitOfProgress = 0.13;
  String _processPhase = '';
  double _progress = 0.0;
  bool _processing = false;

  void getVideos(User user, CollectionReference parentVideoReference) async {
    if (!(state is VideosSuccess)) {
      emit(Loading());
    }
    try {
      _videoList =
          await VideoRepository.getVideosByUser(user.uid, parentVideoReference);
      emit(VideosSuccess(videos: _videoList));
    } catch (e) {
      print(e.toString());
      emit(Failure(exception: e));
    }
  }

  void createVideo(Video video, CollectionReference reference) async {
    if (!(state is VideosSuccess)) {
      emit(Loading());
    }
    try {
      Video newVideo =
          await VideoRepository.createVideo(video, reference);
      _videoList.insert(0, newVideo);
      emit(VideosSuccess(videos: _videoList));
    } catch (e) {
      emit(Failure(exception: e));
    }
  }

  /*void takeVideo(User user, ImageSource imageSource,
      {Video parentVideo}) async {
    if (_imagePickerActive) return;

    _imagePickerActive = true;
    ImagePicker _imagePicker = new ImagePicker();
    PickedFile videoFile = await _imagePicker.getVideo(source: imageSource);
    _imagePickerActive = false;
    if (videoFile == null) return;

    _processing = true;
    emit(TakeVideoSuccess(processing: _processing));

    try {
      File file = File(videoFile.path);
      await _processVideo(user, file, parentVideo: parentVideo);
    } catch (e) {
      print('${e.toString()}');
    } finally {
      _processing = false;
      emit(TakeVideoSuccess(processing: _processing));
    }
  }

  Future<void> _processVideo(User user, File rawVideoFile,
      {Video parentVideo}) async {
    _progress = 0.0;
    emit(TakeVideoSuccess(progress: _progress));

    final String rand = '${new Random().nextInt(10000)}';
    final videoName = 'video$rand';
    final Directory extDir = await getApplicationDocumentsDirectory();
    final outDirPath = '${extDir.path}/Videos/$videoName';
    final videosDir = new Directory(outDirPath);
    videosDir.createSync(recursive: true);

    final rawVideoPath = rawVideoFile.path;
    final info = await EncodingProvider.getMediaInformation(rawVideoPath);
    final aspectRatio =
        EncodingProvider.getAspectRatio(info.getAllProperties());

    _processPhase = 'Generating thumbnail';
    _progress += _unitOfProgress;
    emit(TakeVideoSuccess(processPhase: _processPhase, progress: _progress));

    final thumbFilePath =
        await EncodingProvider.getThumb(rawVideoPath, 100, 150);

    _processPhase = 'Encoding video';
    _progress += _unitOfProgress;
    emit(TakeVideoSuccess(processPhase: _processPhase, progress: _progress));

    final encodedFilesDir =
        await EncodingProvider.encodeHLS(rawVideoPath, outDirPath);

    _processPhase = 'Uploading thumbnail to cloud storage';
    _progress += _unitOfProgress;
    emit(TakeVideoSuccess(processPhase: _processPhase, progress: _progress));

    final thumbUrl = await _uploadFile(thumbFilePath, 'thumbnail');
    final videoUrl = await _uploadHLSFiles(encodedFilesDir, videoName);

    final video = Video(
      url: videoUrl,
      thumbUrl: thumbUrl,
      coverUrl: thumbUrl,
      createdBy: user.uid,
      aspectRatio: aspectRatio,
      uploadedAt: DateTime.now().millisecondsSinceEpoch,
      name: videoName,
    );

    _processPhase = 'Saving video metadata to cloud storage';
    _progress += _unitOfProgress;
    emit(TakeVideoSuccess(processPhase: _processPhase, progress: _progress));

    if (parentVideo == null) {
      createVideo(video);
    } else if (widget.videoParent == null) {
      createVideoResponse(parentVideo.id, video, "/");
    } else if (parentVideo.id == widget.videoParent.id) {
      createVideoResponse(parentVideo.id, video, widget.videoParentPath);
    } else {
      createVideoResponse(
          parentVideo.id,
          video,
          widget.videoParentPath == '/'
              ? widget.videoParent.id
              : '${widget.videoParentPath}/${widget.videoParent.id}');
    }

    _processPhase = '';
    _progress += _unitOfProgress;
    _processing = false;
    emit(TakeVideoSuccess(
        processPhase: _processPhase,
        progress: _progress,
        processing: _processing));
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

      double fileProgress = 0.3 / files.length.toDouble();
      _processPhase = 'Uploading video part file $i out of ${files.length}';
      _progress += fileProgress;
      emit(TakeVideoSuccess(processPhase: _processPhase, progress: _progress));

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
  }*/
}
