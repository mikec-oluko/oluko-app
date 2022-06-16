// ignore_for_file: avoid_dynamic_calls
import 'package:oluko_app/helpers/s3_provider.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;
import 'dart:io';

class VideoProcess {
  static Future<String> uploadFile(String filePath, String folderName, [int duration]) async {
    final file = File(filePath);
    final basename = p.basename(filePath);

    final S3Provider s3Provider = S3Provider();
    final String downloadUrl = await s3Provider.putFile(file.readAsBytesSync(), folderName, basename);

    return downloadUrl;
  }

  static void updatePlaylistUrls(File file, String videoName, {bool s3Storage}) {
    final lines = file.readAsLinesSync();
    final updatedLines = [];

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
}
