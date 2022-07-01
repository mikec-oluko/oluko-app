import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/helpers/s3_provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:path/path.dart' as p;

class ImageUploadService{
    static Future<String> uploadImageToStorage(String filePath, String path,String documentFieldPath) async {
    final file = File(filePath);
    final basename = p.basename(filePath);
    try {
      final Reference fileReference =
          FirebaseStorage.instance.ref('${path}/${basename}');
      await fileReference.putFile(file,SettableMetadata(
    customMetadata: <String, String>{
          'documentPath': path,
          'documentFieldPath': documentFieldPath,
        },
  ));
      final downloadUrl = await fileReference.getDownloadURL();
      return downloadUrl;
    } on Exception catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
   static Future<String> uploadImageToS3(String filePath, String folderName) async {
    final file = File(filePath);
    final basename = p.basename(filePath);

    final S3Provider s3Provider = S3Provider();
    final String downloadUrl = await s3Provider.putFile(file.readAsBytesSync(), folderName, basename);

    return downloadUrl;
  }
}