import 'dart:io';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter_ffmpeg/log.dart';
import 'package:flutter_ffmpeg/media_information.dart';
import 'package:flutter_ffmpeg/statistics.dart';

removeExtension(String path) {
  final str = path.substring(0, path.length - 4);
  return str;
}

class EncodingProvider {
  static final FlutterFFmpeg _encoder = FlutterFFmpeg();
  static final FlutterFFprobe _probe = FlutterFFprobe();
  static final FlutterFFmpegConfig _config = FlutterFFmpegConfig();

  static Future<String> encodeHLS(String videoPath, String outDirPath) async {
    assert(File(videoPath).existsSync());

    // final arguments = '-y -i $videoPath ' +
    //     '-preset ultrafast -g 48 -sc_threshold 0 ' +
    //     '-map 0:0 -map 0:1 -map 0:0 -map 0:1 ' +
    //     '-c:v:0 libx264 -b:v:0 2000k ' +
    //     '-c:v:1 libx264 -b:v:1 1000k ' +
    //     '-c:a copy ' +
    //     '-var_stream_map "v:0,a:0 v:1,a:1" ' +
    //     '-master_pl_name master.m3u8 ' +
    //     '-f hls -hls_time 6 -hls_list_size 0 ' +
    //     '-hls_segment_filename "$outDirPath/%v_fileSequence_%d.ts" ' +
    //     '$outDirPath/%v_playlistVariant.m3u8';

    final arguments = '-y -i $videoPath ' +
        '-preset ultrafast -g 48 -sc_threshold 0 ' +
        '-map 0:0 -map 0:1 -map 0:0 -map 0:1 ' +
        '-c:v:0 libx264 -b:v:0 2000k ' +
        '-c:v:1 libx264 -b:v:1 1000k ' +
        '-c:a copy ' +
        '-var_stream_map "v:0,a:0 v:1,a:1" ' +
        '-master_pl_name master.m3u8 ' +
        '-f hls -hls_time 6 -hls_list_size 0 ' +
        '-hls_segment_filename "$outDirPath/%v_fileSequence_%d.ts" ' +
        '$outDirPath/%v_playlistVariant.m3u8';

    final int rc = await _encoder.execute(arguments);
    assert(rc == 0);

    return outDirPath;
  }

  static Future<String> encode264(String videoPath, String outDirPath) async {
    assert(File(videoPath).existsSync());

    // final arguments = '-i $videoPath ' +
    //     '-vcodec libx264 -vprofile high -preset slow -b:v 500k -maxrate 500k -bufsize 1000k -vf ' +
    //     'scale=-1:360 -threads 0 -acodec libvo_aacenc -b:a 128k $outDirPath/converted.mp4';

    final arguments = '-i $videoPath '
        '-vcodec libx264 '
        '-crf 27 '
        '-preset ultrafast '
        "-y $outDirPath/${'converted.mp4'}";

    final int rc = await _encoder.execute(arguments);
    assert(rc == 0);

    return '$outDirPath/converted.mp4';
  }

  static double getAspectRatio(Map<dynamic, dynamic> info) {
    //TODO Support Gallery
    final int width = int.tryParse(info['streams'][0]['width'].toString());
    final int height = int.tryParse(info['streams'][0]['height'].toString());
    final double aspect = height / width;
    return aspect;
  }

  static Future<String> getThumb(String videoPath, width, height) async {
    assert(await File(videoPath).exists());
    var imagePath = videoPath;
    if (videoPath.toString().contains('.mp4')) {
      imagePath = (videoPath.toString().substring(0, (videoPath.toString().length) - 4));
    }
    final String outPath = '$imagePath.jpeg';
    var arguments = '-y -i $videoPath -vframes 1 -an -s ${width}x${height} -ss 1 $outPath';
    int rc = await _encoder.execute(arguments);
    assert(rc == 0);
    assert(await File(outPath).exists());

    return outPath;
  }

  static void enableStatisticsCallback(void Function(Statistics) cb) {
    return _config.enableStatisticsCallback(cb);
  }

  static Future<void> cancel() async {
    await _encoder.cancel();
  }

  static Future<MediaInformation> getMediaInformation(String path) async {
    assert(File(path).existsSync());

    return await _probe.getMediaInformation(path);
  }

  static double getDuration(Map<dynamic, dynamic> info) {
    return double.parse(info['duration'].toString());
  }

  static void enableLogCallback(void Function(Log log) logCallback) {
    _config.enableLogCallback(logCallback);
  }
}
