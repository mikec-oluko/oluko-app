import 'dart:io';
import 'dart:isolate';

import 'package:camera/camera.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/helpers/encoding_provider.dart';
import 'package:oluko_app/helpers/video_thumbnail.dart';
import 'package:oluko_app/models/assessment.dart';
import 'package:oluko_app/models/assessment_assignment.dart';
import 'package:oluko_app/models/coach_request.dart';
import 'package:oluko_app/models/enums/file_extension_enum.dart';
import 'package:oluko_app/models/segment_submission.dart';
import 'package:oluko_app/models/submodels/video.dart';
import 'package:oluko_app/models/task_submission.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/file_processing.dart';
import 'package:oluko_app/utils/time_converter.dart';
import 'package:oluko_app/utils/video_process.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:video_player/video_player.dart';
import 'package:path/path.dart' as path;
import '../helpers/video_player_helper.dart';
import '../isolate/isolate_manager.dart';

import '../isolate/video_upload_service.dart';
import '../main.dart';
import '../services/video_service.dart';

abstract class VideoState {}

class Loading extends VideoState {}

class VideoSuccess extends VideoState {
  Video video;
  SegmentSubmission segmentSubmission;
  AssessmentAssignment assessmentAssignment;
  Assessment assessment;
  TaskSubmission taskSubmission;
  int taskIndex;
  double aspectRatio;
  bool isLastTask;
  CoachRequest coachRequest;
  VideoSuccess(
      {this.video,
      this.segmentSubmission,
      this.assessment,
      this.assessmentAssignment,
      this.taskSubmission,
      this.taskIndex,
      this.aspectRatio,
      this.coachRequest,
      this.isLastTask});
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
  SegmentSubmission segmentSubmission;
  VideoFailure({this.exceptionMessage, this.segmentSubmission});
}

class VideoBloc extends Cubit<VideoState> {
  VideoBloc() : super(Loading());

  double _unitOfProgress = 0.19;
  String _processPhase = '';
  double _progress = 0.0;

  Future<void> createVideo(
    BuildContext context,
    File videoFile,
    double aspectRatio,
    String id, {
    SegmentSubmission segmentSubmission,
    AssessmentAssignment assessmentAssignment,
    Assessment assessment,
    TaskSubmission taskSubmission,
    bool isLastTask,
    CoachRequest coachRequest,
    int tries = 0,
    int durationInMilliseconds = 0,
  }) async {
    try {
      if (durationInMilliseconds == 0) {
        // ignore: parameter_assignments
        durationInMilliseconds = await VideoService.getVideoDuration(videoFile);
      }
      String thumbnailFilePath;
      try {
        thumbnailFilePath = await VideoService.createVideoThumbnail(videoFile.path);
      } catch (e, stackTrace) {
        thumbnailFilePath = null;
      }
      if (GlobalConfiguration().getString('uploadOnIsolate') == 'true') {
        // A Stream that handles communication between isolates
        final p = ReceivePort();

        final data = {
          'port': p.sendPort,
          'data': {
            'context': context.toString(),
            'videoFilePath': videoFile.path,
            'aspectRatio': aspectRatio,
            'id': id,
            'directory': (await getApplicationDocumentsDirectory()).path,
            'duration': durationInMilliseconds,
            'thumbnailPath': thumbnailFilePath,
          }
        };

        // you can also manage the isolate outside
        // isolate.kill / pause / addListener.. .
        final isolate = await Isolate.spawn(processVideoOnBackground, data);

        p.listen(
          (onData) {
            OlukoIsolateMessage isolateMessage = onData is OlukoIsolateMessage ? onData : null;
            if (isolateMessage != null) {
              if (isolateMessage.status == IsolateStatusEnum.success) {
                emit(
                  VideoSuccess(
                      video: Video.fromJson(isolateMessage.video),
                      segmentSubmission: segmentSubmission,
                      taskSubmission: taskSubmission,
                      assessment: assessment,
                      assessmentAssignment: assessmentAssignment,
                      isLastTask: isLastTask,
                      coachRequest: coachRequest),
                );
              } else {
                emit(VideoFailure());
              }
            }
          },
        );
      } else {
        Video video = await VideoService.processVideoWithoutEncoding(
          videoFile.path,
          aspectRatio,
          id,
          (await getApplicationDocumentsDirectory()).path,
          durationInMilliseconds,
          thumbnailFilePath,
        );

        if (video != null) {
          emit(
            VideoSuccess(
                video: video,
                segmentSubmission: segmentSubmission,
                taskSubmission: taskSubmission,
                assessment: assessment,
                assessmentAssignment: assessmentAssignment,
                isLastTask: isLastTask,
                coachRequest: coachRequest),
          );
        } else {
          emit(VideoFailure());
        }
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      if (tries < 2) {
        await Future.delayed(const Duration(seconds: 5), () async {
          await createVideo(
            context,
            videoFile,
            aspectRatio,
            id,
            segmentSubmission: segmentSubmission,
            assessmentAssignment: assessmentAssignment,
            assessment: assessment,
            taskSubmission: taskSubmission,
            isLastTask: isLastTask,
            coachRequest: coachRequest,
            tries: tries + 1,
          );
        });
      } else {
        emit(VideoFailure(exceptionMessage: e.toString(), segmentSubmission: segmentSubmission));
        rethrow;
      }
    }
  }

  Future<Video> _processVideo(BuildContext context, File videoFile, double aspectRatio, String id) async {
    print('DEPRECATED USE createVideo');
    String videoName = id;
    Video video = Video(name: videoName, aspectRatio: aspectRatio);

    // _processPhase = '';
    // _progress = 0.0;
    //emit(VideoProcessing(processPhase: _processPhase, progress: _progress));

    final Directory extDir = await getApplicationDocumentsDirectory();
    final outDirPath = '${extDir.path}/Videos/$videoName';
    final videosDir = new Directory(outDirPath);
    videosDir.createSync(recursive: true);
    final videoPath = videoFile.path;
    VideoPlayerController controller = VideoPlayerHelper.videoPlayerControllerFromFile(videoFile);
    controller.initialize();
    var durationInSeconds = controller.value.duration;
    controller.dispose();
    int durationInMilliseconds = TimeConverter.fromSecondsToMilliSeconds(durationInSeconds.inSeconds.roundToDouble()).toInt();
    video.duration = durationInMilliseconds;

    //_processPhase = OlukoLocalizations.get(context, 'generatingThumbnail');
    //_progress += _unitOfProgress;
    //emit(VideoProcessing(processPhase: _processPhase, progress: _progress));
    String thumbFilePath;
    try {
      var imagePath = videoPath;
      if (videoPath.toString().contains('.mp4')) {
        imagePath = videoPath.toString().substring(0, (videoPath.toString().length) - 4);
      }
      final String outPath = '$imagePath.jpeg';
      await genThumbnail(ThumbnailRequest(
        video: videoPath,
        maxWidth: 100,
        maxHeight: 150,
        thumbnailPath: outPath,
      ));
      thumbFilePath = outPath;
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      rethrow;
    }

    // _processPhase = OlukoLocalizations.get(context, 'encodingVideo');
    // _progress += _unitOfProgress;
    // emit(VideoProcessing(processPhase: _processPhase, progress: _progress));

    // final encodedFilesDir = await EncodingProvider.encodeHLS(videoPath, outDirPath);
    // emit(VideoEncoded(encodedFilesDir: encodedFilesDir, video: video, thumbFilePath: thumbFilePath));

    //_processPhase = OlukoLocalizations.get(context, 'uploadingThumbnail');
    //_progress += _unitOfProgress;
    //emit(VideoProcessing(processPhase: _processPhase, progress: _progress));

    return video = await uploadVideo(video, thumbFilePath, videoPath, context);
  }

  Future<Video> uploadVideo(Video video, String thumbFilePath, String encodedFilesDir, BuildContext context) async {
    print('DEPRECATED USE createVideo');
    String thumbUrl;
    if (thumbFilePath != null) {
      thumbUrl = await VideoProcess.uploadFile(thumbFilePath, video.name);
    }
    final videoUrl = await _uploadFiles(context, encodedFilesDir, video.name);

    video.url = videoUrl;
    video.thumbUrl = thumbUrl;

    return video;
  }

  void getAspectRatio(String videoUrl) async {
    if (videoUrl != null) {
      double aspectRatio;
      VideoPlayerController _controller = await VideoPlayerController.network(videoUrl);
      if (_controller != null) {
        _controller.initialize().then((value) {
          aspectRatio = _controller.value.aspectRatio;
          emit(VideoSuccess(aspectRatio: aspectRatio));
        });
      }
    } else {
      return emit(VideoSuccess(aspectRatio: 0.6));
    }
  }

  Future<Video> uploadVideoWithoutProcessing(Video video, String thumbFilePath, String filePath, BuildContext context) async {
    print('DEPRECATED USE createVideo');
    String thumbUrl;
    if (thumbFilePath != null) {
      thumbUrl = await VideoProcess.uploadFile(thumbFilePath, video.name);
    }

    //emit(VideoProcessing(processPhase: OlukoLocalizations.get(context, 'uploadingVideoFile'), progress: 0));
    final videoUrl = await VideoProcess.uploadFile(filePath, video.name);
    //emit(VideoProcessing(processPhase: _processPhase, progress: _progress));

    video.url = videoUrl;
    video.thumbUrl = thumbUrl;

    return video;
  }

  Future<String> _uploadFiles(BuildContext context, String dirPath, String videoName) async {
    print('DEPRECATED USE createVideo');
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
      //_processPhase = OlukoLocalizations.get(context, 'uploadingVideoFile') +
      i.toString() + OlukoLocalizations.get(context, 'outOf') + files.length.toString();
      _progress += fileProgress;
      //emit(VideoProcessing(processPhase: _processPhase, progress: _progress));

      final downloadUrl = await VideoProcess.uploadFile(file.path, videoName);

      if (fileName == 'master.m3u8') {
        playlistUrl = downloadUrl;
      }
      i++;
    }

    return playlistUrl;
  }

  Future<Video> _processVideoWithoutEncoding(BuildContext context, File videoFile, double aspectRatio, String id) async {
    print('DEPRECATED USE createVideo');
    String videoName = id;
    Video video = Video(name: videoName, aspectRatio: aspectRatio);
    _processPhase = '';
    _progress = 0.0;
    //emit(VideoProcessing(processPhase: _processPhase, progress: _progress));
    final Directory extDir = await getApplicationDocumentsDirectory();
    final outDirPath = '${extDir.path}/Videos/$videoName';
    final videosDir = new Directory(outDirPath);
    videosDir.createSync(recursive: true);
    final videoPath = videoFile.path;
    // final info = await EncodingProvider.getMediaInformation(videoPath);
    VideoPlayerController controller = VideoPlayerHelper.videoPlayerControllerFromFile(videoFile);
    await controller.initialize();
    double durationInSeconds = controller.value.duration.inSeconds.toDouble(); //EncodingProvider.getDuration(info.getMediaProperties());
    controller.dispose();
    int durationInMilliseconds = TimeConverter.fromSecondsToMilliSeconds(durationInSeconds).toInt();
    video.duration = durationInMilliseconds;
    _processPhase = OlukoLocalizations.get(context, 'generatingThumbnail');
    _progress += _unitOfProgress;
    //emit(VideoProcessing(processPhase: _processPhase, progress: _progress));
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

    //_processPhase = OlukoLocalizations.get(context, 'uploadingThumbnail');
    //_progress += _unitOfProgress;
    //emit(VideoProcessing(processPhase: _processPhase, progress: _progress));

    return video = await uploadVideoWithoutProcessing(video, thumbFilePath, videoPath, context);
  }
}
