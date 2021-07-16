import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oluko_app/helpers/s3_provider.dart';
import 'package:oluko_app/models/enums/file_type_enum.dart';
import 'package:oluko_app/models/transformation_journey_uploads.dart';
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
  Future<List<TransformationJourneyUpload>> getUploadedContentByUserName(
      String userName) async {
    try {
      QuerySnapshot docRef = await FirebaseFirestore.instance
          .collection('projects')
          .doc(GlobalConfiguration().getValue("projectId"))
          .collection('users')
          .doc(userName)
          .collection('transformationJourneyUploads')
          .get();

      // var first = docRef.docs[0].data();
      // final content = TransformationJourneyUpload.fromJson(first);
      // return [content];
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

  //TODO: UPDATE PHOTO FOR TRANSFORMATION JOURNEY GALLERY
  static Future<TransformationJourneyUpload> createTransformationJourneyUpload(
      FileTypeEnum type, PickedFile file, String username) async {
    CollectionReference transformationJourneyUploadsReference = projectReference
        .collection('users')
        .doc(username)
        .collection('transformationJourneyUploads');

    //TODO: get thumbnail here and upload with https://pub.dev/packages/thumbnailer

    final downloadUrl = await _uploadFile(
        file.path, transformationJourneyUploadsReference.path);

    TransformationJourneyUpload transformationJourneyUpload =
        TransformationJourneyUpload(
            name: '',
            from: Timestamp.now(),
            description: '',
            index: 0,
            type: type,
            file: downloadUrl,
            isPublic: true,
            thumbnail: downloadUrl);
//TODO: update thumbnail with thumbnailer https://pub.dev/packages/thumbnailer
    final DocumentReference docRef =
        transformationJourneyUploadsReference.doc();
    transformationJourneyUpload.id = docRef.id;
    docRef.set(transformationJourneyUpload.toJson());
    return transformationJourneyUpload;
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
