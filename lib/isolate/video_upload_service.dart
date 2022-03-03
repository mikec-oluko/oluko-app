import 'dart:isolate';

import 'package:oluko_app/services/video_service.dart';

import '../models/submodels/video.dart';
import 'isolate_manager.dart';

Future<void> processVideoOnBackground(Map<String, dynamic> map) async {
  final SendPort port = map['port'] as SendPort;
  final Map<String, dynamic> data = map['data'] as Map<String, dynamic>;
  Video video;
  try {
    // Heavy computing process
    video = await VideoService.processVideoWithoutEncoding(data['videoFilePath'] as String, data['aspectRatio'] as double,
        data['id'] as String, port, data['directory'] as String, data['duration'] as int, data['thumbnailPath'] as String);

    port.send(OlukoIsolateMessage(IsolateStatusEnum.success, video: video.toJson()));
  } catch (e) {
    port.send(OlukoIsolateMessage(IsolateStatusEnum.failure));
    rethrow;
  }
  Isolate.exit(port, video);
}
