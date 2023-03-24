import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oluko_app/helpers/s3_provider.dart';
import 'package:oluko_app/models/enums/file_type_enum.dart';
import 'package:oluko_app/models/transformation_journey_uploads.dart';
import 'package:oluko_app/services/video_service.dart';
import 'package:oluko_app/utils/image_utils.dart';
import 'package:oluko_app/utils/video_process.dart';
import 'package:path/path.dart' as p;
import 'package:sentry_flutter/sentry_flutter.dart';

class TransformationJourneyRepository {
  FirebaseFirestore firestoreInstance;

  static DocumentReference projectReference = FirebaseFirestore.instance.collection('projects').doc(GlobalConfiguration().getString('projectId'));

  TransformationJourneyRepository() {
    firestoreInstance = FirebaseFirestore.instance;
  }

  TransformationJourneyRepository.test({this.firestoreInstance});

  Future<List<TransformationJourneyUpload>> getUploadedContentByUserId(String userId) async {
    try {
      final QuerySnapshot docRef = await FirebaseFirestore.instance
          .collection('projects')
          .doc(GlobalConfiguration().getString('projectId'))
          .collection('users')
          .doc(userId)
          .collection('transformationJourneyUploads')
          .where('is_deleted', isNotEqualTo: true)
          .get();
      final List<TransformationJourneyUpload> contentUploaded = [];
      for (final doc in docRef.docs) {
        final Map<String, dynamic> content = doc.data() as Map<String, dynamic>;
        contentUploaded.add(TransformationJourneyUpload.fromJson(content));
      }
      contentUploaded.sort((a, b) => b.index.compareTo(a.index));
      return contentUploaded;
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  static Future<TransformationJourneyUpload> createTransformationJourneyUpload(FileTypeEnum type, XFile file, String userId, int index) async {
    try {
      final CollectionReference transformationJourneyUploadsReference =
          projectReference.collection('users').doc(userId).collection('transformationJourneyUploads');

      String thumbnail;

      switch (type) {
        case FileTypeEnum.image:
          thumbnail = await ImageUtils().getThumbnailForImage(file, 150);
          break;
        case FileTypeEnum.video:
          thumbnail = await VideoService.createVideoThumbnail(file.path);
          break;
        default:
          //TODO Handle PDF Uploads
          break;
      }
      if (type == FileTypeEnum.image) {
        final thumbNaildownloadUrl = await _uploadFile(thumbnail, '${transformationJourneyUploadsReference.path}/thumbnails');

        final smallerDownloadUrl = await ImageUtils().getThumbnailForImage(file, 600);
        final downloadUrl = await _uploadFile(smallerDownloadUrl, transformationJourneyUploadsReference.path);

        final TransformationJourneyUpload transformationJourneyUpload = TransformationJourneyUpload(
            createdBy: userId,
            name: '',
            from: Timestamp.now(),
            description: '',
            index: index ?? 0,
            type: type,
            file: downloadUrl,
            isPublic: true,
            isDeleted: false,
            thumbnail: thumbNaildownloadUrl);
//TODO: update thumbnail with thumbnailer https://pub.dev/packages/thumbnailer
        final DocumentReference docRef = transformationJourneyUploadsReference.doc();
        transformationJourneyUpload.id = docRef.id;
        docRef.set(transformationJourneyUpload.toJson());
        return transformationJourneyUpload;
      } else {}
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
    return null;
  }

  static Future<String> _uploadFile(String filePath, String folderName) async {
    final file = File(filePath);
    final basename = p.basename(filePath);

    final S3Provider s3Provider = S3Provider();
    final String downloadUrl = await s3Provider.putFile(file.readAsBytesSync(), folderName, basename);

    return downloadUrl;
  }

  static Future<bool> reorderElementsIndex({TransformationJourneyUpload elementMoved, TransformationJourneyUpload elementReplaced, String userId}) async {
    updateIndexOfElements(elementMoved, elementReplaced);

    try {
      await updateDocument(userId, elementMoved);
      await updateDocument(userId, elementReplaced);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }

      return false;
    }
  }

  Future<bool> markElementAsDeleted({String userId, TransformationJourneyUpload transformationJourneyItem}) async {
    try {
      final DocumentReference contentReference =
          projectReference.collection('users').doc(userId).collection('transformationJourneyUploads').doc(transformationJourneyItem.id);
      transformationJourneyItem.isDeleted = true;
      await contentReference.update(transformationJourneyItem.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future updateDocument(String userId, TransformationJourneyUpload elementToUpdate) async {
    final DocumentReference contentReference =
        projectReference.collection('users').doc(userId).collection('transformationJourneyUploads').doc(elementToUpdate.id);
    await contentReference.update(elementToUpdate.toJson());
  }

  static void updateIndexOfElements(TransformationJourneyUpload elementMoved, TransformationJourneyUpload elementReplaced) {
    final temptElement = elementMoved.index;
    elementMoved.index = elementReplaced.index;
    elementReplaced.index = temptElement;
  }
}
