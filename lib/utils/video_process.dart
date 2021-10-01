import 'dart:developer';

import 'package:flutter_ffmpeg/media_information.dart';
import 'package:flutter_ffmpeg/stream_information.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oluko_app/helpers/encoding_provider.dart';
import 'package:oluko_app/helpers/s3_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

import 'package:sentry_flutter/sentry_flutter.dart';

class VideoProcess {
  static Future<String> uploadFile(String filePath, String folderName) async {
    final file = new File(filePath);
    final basename = p.basename(filePath);

    final S3Provider s3Provider = S3Provider();
    String downloadUrl = await s3Provider.putFile(file.readAsBytesSync(), folderName, basename);

    return downloadUrl;
  }

  static void updatePlaylistUrls(File file, String videoName, {bool s3Storage}) {
    final lines = file.readAsLinesSync();
    var updatedLines = [];

    for (final String line in lines) {
      var updatedLine = line;
      if (line.contains('.ts') || line.contains('.m3u8')) {
        updatedLine = s3Storage == null ? '$videoName%2F$line?alt=media' : '$line?alt=media';
      }
      updatedLines.add(updatedLine);
    }
    final String updatedContents = updatedLines.reduce((value, element) => value + '\n' + element).toString();

    file.writeAsStringSync(updatedContents);
  }

  ///Generate a thumbnail for a Video with the specified width & height.
  static Future<String> getThumbnailForVideo(PickedFile video, int width, {int height}) async {
    MediaInformation videoInfo = await EncodingProvider.getMediaInformation(video.path);

    if (height == null) {
      StreamInformation videoProperties =
          videoInfo.getStreams().where((element) => element.getAllProperties()['width'] != null).toList()[0];
      double aspectRatio = double.tryParse(videoProperties.getAllProperties()['width'].toString()) /
          double.tryParse(videoProperties.getAllProperties()['height'].toString());
      //The operator '~/' get the closest int to the operation
      height = (width ~/ aspectRatio);
    }
    var properties = videoInfo.getAllProperties();
    try {
      String thumbnailPath = await EncodingProvider.getThumb(video.path, width, height);
      return thumbnailPath;
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      log(e.toString());
      rethrow;
    }
  }
}
