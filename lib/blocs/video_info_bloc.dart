import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oluko_app/helpers/encoding_provider.dart';
import 'package:oluko_app/helpers/s3_provider.dart';
import 'package:oluko_app/models/submodels/draw_point.dart';
import 'package:oluko_app/models/submodels/event.dart';
import 'package:oluko_app/models/submodels/video.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:oluko_app/models/submodels/video_info.dart';
import 'package:oluko_app/repositories/video_info_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:video_player/video_player.dart';
import '../helpers/video_player_helper.dart';
import '../helpers/video_thumbnail.dart';

abstract class VideoInfoState {
  final List<VideoInfo> videoInfoList;
  final List<double> markerList;
  const VideoInfoState({this.videoInfoList, this.markerList});
}

class Loading extends VideoInfoState {}

class VideoInfoSuccess extends VideoInfoState {
  final List<VideoInfo> videosInfo;

  const VideoInfoSuccess({this.videosInfo}) : super(videoInfoList: videosInfo);
}

class MarkersSuccess extends VideoInfoState {
  final List<double> markers;

  const MarkersSuccess({this.markers}) : super(markerList: markers);
}

class DrawingSuccess extends VideoInfoState {}

class TakeVideoSuccess extends VideoInfoState {
  final String processPhase;
  final double progress;
  TakeVideoSuccess({this.processPhase, this.progress});
}

class Failure extends VideoInfoState {
  final dynamic exception;

  Failure({this.exception});
}

class VideoInfoBloc extends Cubit<VideoInfoState> {
  VideoInfoBloc() : super(Loading());

  bool _imagePickerActive = false;
  double _unitOfProgress = 0.19;
  String _processPhase = '';
  double _progress = 0.0;

  List<VideoInfo> _videoInfoList = [];
  List<double> _markerList = [];

  void addMarkerToVideoInfo(double position, DocumentReference reference) async {
    /*if (!(state is MarkersSuccess)) {
      emit(Loading());
    }*/
    try {
      double newMarker = await VideoInfoRepository.addMarkerToVideoInfo(position, reference);
      _markerList.insert(0, newMarker);
      //emit(MarkersSuccess(markers: _markerList));
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      print(e.toString());
      //emit(Failure(exception: e));
      rethrow;
    }
  }

  void addDrawingToVideoInfo(List<DrawPoint> canvasPointsRecording, DocumentReference reference) async {
    /*if (!(state is DrawingSuccess)) {
      emit(Loading());
    }*/
    try {
      await VideoInfoRepository.addDrawingToVideoInfo(canvasPointsRecording, reference);
      //emit(DrawingSuccess());
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      print(e.toString());
      //emit(Failure(exception: e));
      rethrow;
    }
  }

  void getVideosInfo(User user, CollectionReference parent) async {
    emit(Loading());
    try {
      _videoInfoList = await VideoInfoRepository.getVideosInfoByUser(user.uid, parent);
      emit(VideoInfoSuccess(videosInfo: _videoInfoList));
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      print(e.toString());
      emit(Failure(exception: e));
      rethrow;
    }
  }

  void createVideoInfo(CollectionReference reference, User user, bool addToList, {Video video, List<Event> events}) {
    emit(Loading());
    try {
      VideoInfo newVideoInfo = VideoInfo(
        //createdBy: user.uid,
        markers: [],
        events: (events != null) ? events : [],
        drawing: [],
        video: video != null ? video : Video(),
      );
      newVideoInfo = VideoInfoRepository.createVideoInfo(newVideoInfo, reference);
      if (addToList) {
        _videoInfoList.insert(0, newVideoInfo);
      }
      emit(VideoInfoSuccess(videosInfo: _videoInfoList));
    } catch (e, stackTrace) {
      Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      emit(Failure(exception: e));
      rethrow;
    }
  }

  void takeVideo(User user, ImageSource imageSource, CollectionReference reference, bool addToList) async {
    if (_imagePickerActive) return;

    _imagePickerActive = true;
    ImagePicker _imagePicker = new ImagePicker();
    PickedFile videoFile = await _imagePicker.getVideo(source: imageSource);
    _imagePickerActive = false;
    if (videoFile == null) return;

    //_processing = true;

    try {
      File file = File(videoFile.path);
      await processVideo(user, file, reference, addToList);
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      print('${e.toString()}');
      rethrow;
    } finally {
      //_processing = false;
    }
  }

  Future<void> processVideo(User user, File rawVideoFile, CollectionReference reference, bool addToList, {double givenAspectRatio, List<Event> events}) async {
    Video video;
    if (givenAspectRatio == null) {
      video = await createVideo(rawVideoFile);
    } else {
      video = await createVideo(rawVideoFile, givenAspectRatio: givenAspectRatio);
    }

    createVideoInfo(reference, user, addToList, video: video, events: events);
  }

  Future<Video> createVideo(File rawVideoFile, {double givenAspectRatio}) async {
    _progress = 0.0;
    emit(TakeVideoSuccess(processPhase: _processPhase, progress: _progress));

    final String rand = '${new Random().nextInt(10000)}';
    final videoName = 'video$rand';
    final Directory extDir = await getApplicationDocumentsDirectory();
    final outDirPath = '${extDir.path}/Videos/$videoName';
    final videosDir = new Directory(outDirPath);
    videosDir.createSync(recursive: true);

    final rawVideoPath = rawVideoFile.path;

    VideoPlayerController controller = VideoPlayerHelper.videoPlayerControllerFromFile(rawVideoFile);
    await controller.initialize();
    var controllerAspectRatio = controller.value.aspectRatio;

    double aspectRatio;

    if (givenAspectRatio != null) {
      aspectRatio = givenAspectRatio;
    } else {
      aspectRatio = controllerAspectRatio;
    }

    double durationInSeconds = controller.value.duration.inSeconds.roundToDouble();
    controller.dispose();
    int durationInMilliseconds = (durationInSeconds * 1000).toInt();

    _processPhase = 'Generating thumbnail';
    _progress += _unitOfProgress;
    emit(TakeVideoSuccess(processPhase: _processPhase, progress: _progress));

    var imagePath = rawVideoPath;
    if (rawVideoPath.contains('.mp4')) {
      imagePath = rawVideoPath.substring(0, (rawVideoPath.toString().length) - 4);
    }
    final String outPath = '$imagePath.jpeg';
    await genThumbnail(ThumbnailRequest(
      video: rawVideoPath,
      maxWidth: 100,
      maxHeight: 150,
      thumbnailPath: outPath,
    ));
    final thumbFilePath = outPath;

    _processPhase = 'Encoding video';
    _progress += _unitOfProgress;
    emit(TakeVideoSuccess(processPhase: _processPhase, progress: _progress));

    // final encodedFilesDir = await EncodingProvider.encodeHLS(rawVideoPath, outDirPath);

    _processPhase = 'Uploading thumbnail to cloud storage';
    _progress += _unitOfProgress;
    emit(TakeVideoSuccess(processPhase: _processPhase, progress: _progress));

    final thumbUrl = await _uploadFile(thumbFilePath, videoName);
    // final videoUrl = await _uploadHLSFiles(encodedFilesDir, videoName);

    final video = Video(
      // url: videoUrl,
      thumbUrl: thumbUrl,
      aspectRatio: aspectRatio,
      name: videoName,
      duration: durationInMilliseconds,
    );
    return video;
  }

  Future<String> _uploadHLSFiles(String dirPath, String videoName) async {
    final videosDir = Directory(dirPath);

    var playlistUrl = '';

    final files = videosDir.listSync();
    int i = 1;
    for (FileSystemEntity file in files) {
      final fileName = p.basename(file.path);
      final fileExtension = getFileExtension(fileName);
      if (fileExtension == 'm3u8') {
        if (file is File) _updatePlaylistUrls(file, videoName, s3Storage: true);
      }

      final double fileProgress = 0.4 / files.length.toDouble();
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

  Future<String> _uploadFile(String filePath, String folderName) async {
    final file = new File(filePath);
    final basename = p.basename(filePath);

    final S3Provider s3Provider = S3Provider();
    String downloadUrl = await s3Provider.putFile(file.readAsBytesSync(), folderName, basename);

    return downloadUrl;
  }

  void _updatePlaylistUrls(File file, String videoName, {bool s3Storage}) {
    final lines = file.readAsLinesSync();
    List<String> updatedLines = [];

    for (final String line in lines) {
      var updatedLine = line;
      if (line.contains('.ts') || line.contains('.m3u8')) {
        updatedLine = s3Storage == null ? '$videoName%2F$line?alt=media' : '$line?alt=media';
      }
      updatedLines.add(updatedLine);
    }
    final String updatedContents = updatedLines.reduce((value, element) => value + '\n' + element);

    file.writeAsStringSync(updatedContents);
  }
}
