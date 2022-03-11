import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/repositories/introduction_media_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class DownloadAssetState {}

class Loading extends DownloadAssetState {}

class Failure extends DownloadAssetState {
  final dynamic exception;
  Failure({this.exception});
}

class DownloadSuccess extends DownloadAssetState {
  final String videoUrl;
  final File videoFile;
  final bool isDownloaded;
  DownloadSuccess( {this.videoUrl, this.videoFile,this.isDownloaded});
}

class DownloadAssetBloc extends Cubit<DownloadAssetState> {
  DownloadAssetBloc() : super(Loading());
  Dio dio = Dio();
  bool downloaded = false;
  void getVideo() async {
    try {
      var dir = await getTemporaryDirectory();
      var videoPath = "${dir.path}/demo.mp4";
      String url = await IntroductionMediaRepository.getVideoURL(IntroductionMediaTypeEnum.completedCourseVideo);
      print("path ${dir.path}");
      if (!downloaded) {
        await dio.download(url, videoPath, onReceiveProgress: (rec, total) {
          if (rec == total) {
            downloaded = true;
          }
        });
      }
      final File file = File(videoPath);

      emit(DownloadSuccess(videoUrl: url, videoFile: file,isDownloaded:downloaded));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(Failure(exception: exception));
      rethrow;
    }
  }
}
