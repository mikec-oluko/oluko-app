import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class ThumbnailRequest {
  final String video;
  final String thumbnailPath;
  final ImageFormat imageFormat;
  final int maxHeight;
  final int maxWidth;
  final int timeMs;
  final int quality;

  const ThumbnailRequest({this.video, this.thumbnailPath, this.imageFormat, this.maxHeight, this.maxWidth, this.timeMs, this.quality});
}

class ThumbnailResult {
  final Image image;
  final int dataSize;
  final int height;
  final int width;
  final String path;
  const ThumbnailResult({this.image, this.dataSize, this.height, this.width, this.path});
}

Future<ThumbnailResult> genThumbnail(ThumbnailRequest r) async {
  //WidgetsFlutterBinding.ensureInitialized();
  Uint8List bytes;
  final Completer<ThumbnailResult> completer = Completer();
  String thumbnailPath;
  if (r.thumbnailPath != null) {
    thumbnailPath = await VideoThumbnail.thumbnailFile(
      video: r.video,
      thumbnailPath: r.thumbnailPath,
      imageFormat: ImageFormat.JPEG,
      // maxHeight: r.maxHeight,
      // maxWidth: r.maxWidth,
      // timeMs: r.timeMs,
      // quality: r.quality
    );

    if (kDebugMode) {
      print('thumbnail file is located: $thumbnailPath');
    }

    final file = File(thumbnailPath);
    bytes = file.readAsBytesSync();
  } else {
    bytes = await VideoThumbnail.thumbnailData(
        video: r.video, imageFormat: r.imageFormat, maxHeight: r.maxHeight, maxWidth: r.maxWidth, timeMs: r.timeMs, quality: r.quality);
  }

  final int _imageDataSize = bytes.length;
  if (kDebugMode) {
    print('image size: $_imageDataSize');
  }

  final _image = Image.memory(bytes);
  _image.image.resolve(ImageConfiguration()).addListener(ImageStreamListener((ImageInfo info, bool _) {
    completer.complete(ThumbnailResult(
      image: _image,
      dataSize: _imageDataSize,
      height: info.image.height,
      width: info.image.width,
      path: thumbnailPath,
    ));
  }));
  return completer.future;
}
