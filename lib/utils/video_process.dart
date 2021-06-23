import 'package:oluko_app/helpers/s3_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

class VideoProcess{
    static Future<String> uploadFile(filePath, folderName) async {
    final file = new File(filePath);
    final basename = p.basename(filePath);

    final S3Provider s3Provider = S3Provider();
    String downloadUrl =
        await s3Provider.putFile(file.readAsBytesSync(), folderName, basename);

    return downloadUrl;
  }

    static void updatePlaylistUrls(File file, String videoName, {bool s3Storage}) {
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