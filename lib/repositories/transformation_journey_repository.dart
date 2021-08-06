import 'dart:io';
import 'package:image/image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oluko_app/helpers/encoding_provider.dart';
import 'package:oluko_app/helpers/s3_provider.dart';
import 'package:oluko_app/models/enums/file_type_enum.dart';
import 'package:oluko_app/models/transformation_journey_uploads.dart';
import 'package:oluko_app/utils/image_utils.dart';
import 'package:oluko_app/utils/video_process.dart';
import 'package:path/path.dart' as p;

class TransformationJourneyRepository {
  FirebaseFirestore firestoreInstance;

  static DocumentReference projectReference = FirebaseFirestore.instance
      .collection("projects")
      .doc(GlobalConfiguration().getValue("projectId"));

  TransformationJourneyRepository() {
    firestoreInstance = FirebaseFirestore.instance;
  }

  TransformationJourneyRepository.test({FirebaseFirestore firestoreInstance}) {
    this.firestoreInstance = firestoreInstance;
  }

  //TODO: Filter or not, userInfo to return only the List
  Future<List<TransformationJourneyUpload>> getUploadedContentByUserId(
      String userId) async {
    try {
      QuerySnapshot docRef = await FirebaseFirestore.instance
          .collection('projects')
          .doc(GlobalConfiguration().getValue("projectId"))
          .collection('users')
          .doc(userId)
          .collection('transformationJourneyUploads')
          .where('is_deleted', isNotEqualTo: true)
          .get();
      List<TransformationJourneyUpload> contentUploaded = [];
      docRef.docs.forEach((doc) {
        final Map<String, dynamic> content = doc.data();
        contentUploaded.add(TransformationJourneyUpload.fromJson(content));
      });

      return contentUploaded;
    } catch (e) {
      throw e;
    }
  }

  static Future<TransformationJourneyUpload> createTransformationJourneyUpload(
      FileTypeEnum type, PickedFile file, String userId) async {
    try {
      CollectionReference transformationJourneyUploadsReference =
          projectReference
              .collection('users')
              .doc(userId)
              .collection('transformationJourneyUploads');

      var thumbnail;

      switch (type) {
        case FileTypeEnum.image:
          thumbnail = await ImageUtils().getThumbnailForImage(file, 250);
          break;
        case FileTypeEnum.video:
          thumbnail = await VideoProcess.getThumbnailForVideo(file, 250);
          break;
        default:
          //TODO Handle PDF Uploads
          break;
      }
      if (type == FileTypeEnum.image) {
        final thumbNaildownloadUrl = await _uploadFile(thumbnail,
            '${transformationJourneyUploadsReference.path}/thumbnails');

        final downloadUrl = await _uploadFile(
            file.path, transformationJourneyUploadsReference.path);

        TransformationJourneyUpload transformationJourneyUpload =
            TransformationJourneyUpload(
                createdBy: userId,
                name: '',
                from: Timestamp.now(),
                description: '',
                index: 0,
                type: type,
                file: downloadUrl,
                isPublic: true,
                isDeleted: false,
                thumbnail: thumbNaildownloadUrl);
//TODO: update thumbnail with thumbnailer https://pub.dev/packages/thumbnailer
        final DocumentReference docRef =
            transformationJourneyUploadsReference.doc();
        transformationJourneyUpload.id = docRef.id;
        docRef.set(transformationJourneyUpload.toJson());
        return transformationJourneyUpload;
      } else {}
    } catch (e) {
      throw e;
    }
  }

  static Future<String> _uploadFile(filePath, folderName) async {
    final file = new File(filePath);
    final basename = p.basename(filePath);

    final S3Provider s3Provider = S3Provider();
    String downloadUrl =
        await s3Provider.putFile(file.readAsBytesSync(), folderName, basename);

    return downloadUrl;
  }
}
