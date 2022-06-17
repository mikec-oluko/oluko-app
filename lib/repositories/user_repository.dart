import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oluko_app/helpers/s3_provider.dart';
import 'package:oluko_app/models/coach_user.dart';
import 'package:oluko_app/models/dto/change_user_information.dart';
import 'package:oluko_app/models/dto/user_dto.dart';
import 'package:oluko_app/models/sign_up_request.dart';
import 'package:oluko_app/models/submodels/audio.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/services/image_upload_service..dart';
import 'package:oluko_app/utils/image_utils.dart';
import 'package:path/path.dart' as p;
import 'package:sentry_flutter/sentry_flutter.dart';

import 'auth_repository.dart';

class UserRepository {
  FirebaseFirestore firestoreInstance;

  UserRepository() {
    firestoreInstance = FirebaseFirestore.instance;
  }

  UserRepository.test({this.firestoreInstance});

  Future<UserResponse> get(String email) async {
    if (email != null) {
      final QuerySnapshot docRef = await FirebaseFirestore.instance
          .collection('projects')
          .doc(GlobalConfiguration().getValue('projectId'))
          .collection('users')
          .where('email', isEqualTo: email.toLowerCase())
          .get();
      if (docRef.docs == null || docRef.docs.isEmpty) {
        return null;
      }
      final response = docRef.docs[0].data() as Map<String, dynamic>;
      final loginResponseBody = UserResponse.fromJson(response);
      return loginResponseBody;
    }
    return null;
  }

  Future<UserResponse> getById(String id) async {
    if (id == null) {
      return null;
    }
    final QuerySnapshot docRef = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue('projectId'))
        .collection('users')
        .where('id', isEqualTo: id)
        .get();
    if (docRef.docs == null || docRef.docs.isEmpty) {
      return null;
    }
    final response = docRef.docs[0].data() as Map<String, dynamic>;
    final loginResponseBody = UserResponse.fromJson(response);
    return loginResponseBody;
  }

  Future<CoachUser> getCoachById(String id) async {
    if (id == null) {
      return null;
    }
    final QuerySnapshot docRef = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue('projectId'))
        .collection('users')
        .where('id', isEqualTo: id)
        .get();
    if (docRef.docs == null || docRef.docs.isEmpty) {
      return null;
    }
    final response = docRef.docs[0].data() as Map<String, dynamic>;
    final loginResponseBody = CoachUser.fromJson(response);
    return loginResponseBody;
  }

  Future<List<UserResponse>> getByAudios(List<Audio> audios) async {
    final List<UserResponse> coaches = [];
    if (audios != null) {
      for (final Audio audio in audios) {
        final DocumentSnapshot ds = await audio.userReference.get();
        final UserResponse retrievedCoach = UserResponse.fromJson(ds.data() as Map<String, dynamic>);
        coaches.add(retrievedCoach);
      }
    }
    return coaches;
  }

  Future<List<UserResponse>> getAll() async {
    final QuerySnapshot docRef =
        await FirebaseFirestore.instance.collection('projects').doc(GlobalConfiguration().getValue('projectId')).collection('users').get();
    if (docRef.docs == null || docRef.docs.isEmpty) {
      return null;
    }
    final List<UserResponse> response = docRef.docs.map((doc) => UserResponse.fromJson(doc.data() as Map<String, dynamic>)).toList();

    return response;
  }

  Future<UserResponse> createSSO(SignUpRequest signUpRequest) async {
    final CollectionReference reference =
        FirebaseFirestore.instance.collection('projects').doc(GlobalConfiguration().getValue('projectId')).collection('users');

    final UserResponse user =
        UserResponse(firstName: signUpRequest.firstName, lastName: signUpRequest.lastName, email: signUpRequest.email);
    final DocumentReference docRef = reference.doc();
    user.id = docRef.id;
    user.username = docRef.id;
    try {
      await docRef.set(user.toJson());
      return user;
    } on Exception catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<UserResponse> getByUsername(String username) async {
    final QuerySnapshot<Map<String, dynamic>> docsRef = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue('projectId'))
        .collection('users')
        .where('username_lowercase', isEqualTo: username.toLowerCase())
        .get();
    if (docsRef.size > 0) {
      final response = docsRef.docs[0].data();
      final loginResponseBody = UserResponse.fromJson(response);
      return loginResponseBody;
    }
    return null;
  }

  Future<UserResponse> updateUserAvatar(UserResponse user, XFile file) async {
    final DocumentReference<Object> userReference = getUserReference(user);

    final thumbnail = await ImageUtils().getThumbnailForImage(file, 500);
    final downloadUrl = await ImageUploadService.uploadImageToStorage(thumbnail, '${userReference.path}/avatar');
    user.avatar = downloadUrl;
    try {
      await userReference.update(user.toJson());
      AuthRepository().storeLoginData(user);
      return user;
    } on Exception catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<UserResponse> updateUserCoverImage({UserResponse user, XFile coverImage}) async {
    final DocumentReference<Object> userReference = getUserReference(user);

    final thumbnail = await ImageUtils().getThumbnailForImage(coverImage, 1000);
    final coverDownloadImage = await ImageUploadService.uploadImageToStorage(thumbnail, '${userReference.path}/coverImage/');
    user.coverImage = coverDownloadImage;
    try {
      await userReference.update(user.toJson());
      AuthRepository().storeLoginData(user);
      return user;
    } on Exception catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  DocumentReference<Object> getUserReference(UserResponse user) {
    final DocumentReference userReference =
        FirebaseFirestore.instance.collection('projects').doc(GlobalConfiguration().getValue('projectId')).collection('users').doc(user.id);
    return userReference;
  }

  Future<UserResponse> updateUserSettingsPreferences(UserResponse user, int privacyIndex) async {
    final DocumentReference<Object> userReference = getUserReference(user);

    user.privacy = privacyIndex;
    try {
      await userReference.update(user.toJson());
      AuthRepository().storeLoginData(user);
      return user;
    } on Exception catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<UserResponse> updateRecordingAlert(UserResponse user) async {
    final DocumentReference<Object> userReference = getUserReference(user);
    user.showRecordingAlert = !user.showRecordingAlert;
    try {
      final userJson = user.toJson();
      await userReference.update(userJson);
      AuthRepository().storeLoginData(user);
      return user;
    } on Exception catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<UserResponse> updateUserLastAssessmentUploaded(UserResponse user, Timestamp lastAssessmentDate) async {
    final DocumentReference<Object> userReference = getUserReference(user);
    user.assessmentsCompletedAt = lastAssessmentDate;
    try {
      await userReference.update(user.toJson());
      AuthRepository().storeLoginData(user);
      return user;
    } on Exception catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  void saveToken(String userId, String token) {
    FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue('projectId'))
        .collection('users')
        .doc(userId)
        .set({'user_token': token}, SetOptions(merge: true));
  }

  Future<Response> updateUserInformation(ChangeUserInformation user, String userId) async {
    final apiToken = await AuthRepository().getApiToken();
    if (apiToken != null) {
      Client http = Client();
      final String url = GlobalConfiguration().getValue('firebaseFunctions').toString() + '/user';
      var body = user.toJson();
      final headers = {
        'Authorization': 'Bearer $apiToken',
      };
      Response response = await http.put(Uri.parse('$url/${userId}'), headers: headers, body: body);
      return response;
    } else {
      return null;
    }

  }
}
