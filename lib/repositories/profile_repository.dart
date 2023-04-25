import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/repositories/user_repository.dart';
import 'auth_repository.dart';

class ProfileRepository {
  FirebaseFirestore firestoreInstance;
  final AuthRepository _authRepository = AuthRepository();
  final UserRepository _userRepository = UserRepository();

  ProfileRepository() {
    firestoreInstance = FirebaseFirestore.instance;
  }

  ProfileRepository.test({FirebaseFirestore firestoreInstance}) {
    this.firestoreInstance = firestoreInstance;
  }

  Future<UserResponse> updateProfileAvatar({XFile image, bool isDeleteRequest = false}) async {
    UserResponse user = await _authRepository.retrieveLoginData();
    UserResponse userUpdated = await UserRepository().updateUserAvatar(user, image, isDeleteRequest: isDeleteRequest);
    return userUpdated;
  }

  Future<UserResponse> uploadProfileCoverImage({XFile image, bool isDeleteRequested = false}) async {
    UserResponse user = await _authRepository.retrieveLoginData();
    UserResponse userUpdated = await _userRepository.updateUserCoverImage(user, image, isDeleteRequest: isDeleteRequested);
    return userUpdated;
  }

  Future<UserResponse> updateUserPreferences(UserResponse user, int privacyIndex) async {
    UserResponse userUpdated = await _userRepository.updateUserSettingsPreferences(user, privacyIndex);
    return userUpdated;
  }

  Future<UserResponse> updateUserPreferencesforWeight(UserResponse user, bool useImperialSystem) async {
    UserResponse userUpdated = await _userRepository.updateUserSettingsForWeightMeasure(user, useImperialSystem);
    return userUpdated;
  }

  Future<UserResponse> updateProfileView() async {
    UserResponse user = await _authRepository.retrieveLoginData();

    return user;
  }
}
