import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mvt_fitness/helpers/s3_provider.dart';
import 'package:mvt_fitness/models/sign_up_request.dart';
import 'package:mvt_fitness/models/sign_up_response.dart';
import 'package:mvt_fitness/models/user_response.dart';
import 'package:path/path.dart' as p;

class UserRepository {
  FirebaseFirestore firestoreInstance;

  UserRepository() {
    firestoreInstance = FirebaseFirestore.instance;
  }

  UserRepository.test({FirebaseFirestore firestoreInstance}) {
    this.firestoreInstance = firestoreInstance;
  }

  Future<UserResponse> get(String email) async {
    QuerySnapshot docRef = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue("projectId"))
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    if (docRef.docs == null || docRef.docs.length == 0) {
      return null;
    }
    var response = docRef.docs[0].data();
    var loginResponseBody = UserResponse.fromJson(response);
    return loginResponseBody;
  }

  Future<UserResponse> createSSO(SignUpRequest signUpRequest) async {
    CollectionReference reference = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue("projectId"))
        .collection('users');

    UserResponse user = UserResponse(
        firstName: signUpRequest.firstName,
        lastName: signUpRequest.lastName,
        email: signUpRequest.email);
    final DocumentReference docRef = reference.doc();
    user.id = docRef.id;
    user.username = docRef.id;
    try {
      await docRef.set(user.toJson());
      return user;
    } on Exception catch (e) {
      return null;
    }
  }

  Future<UserResponse> getByUsername(String username) async {
    DocumentSnapshot<Map<String, dynamic>> docRef = await FirebaseFirestore
        .instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue("projectId"))
        .collection('users')
        .doc(username)
        .get();
    var response = docRef.data();
    var loginResponseBody = UserResponse.fromJson(response);
    return loginResponseBody;
  }

  Future<UserResponse> updateUserAvatar(
      UserResponse user, PickedFile file) async {
    DocumentReference userReference = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue("projectId"))
        .collection('users')
        .doc(user.username);

    final downloadUrl = await _uploadFile(file.path, userReference.path);
    user.avatar = downloadUrl;
    try {
      await userReference.update(user.toJson());
      return user;
    } on Exception catch (e) {
      return null;
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
