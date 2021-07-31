import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/repositories/user_repository.dart';
import 'auth_repository.dart';

class ProfileRepository {
  FirebaseFirestore firestoreInstance;

  ProfileRepository() {
    firestoreInstance = FirebaseFirestore.instance;
  }

  ProfileRepository.test({FirebaseFirestore firestoreInstance}) {
    this.firestoreInstance = firestoreInstance;
  }

  Future<UserResponse> updateProfileAvatar(PickedFile image) async {
    UserResponse user = await AuthRepository().retrieveLoginData();
    UserResponse userUpdated =
        await UserRepository().updateUserAvatar(user, image);
    return userUpdated;
  }

  Future<UserResponse> uploadProfileCoverImage(PickedFile image) async {
    UserResponse user = await AuthRepository().retrieveLoginData();
    UserResponse userUpdated = await UserRepository()
        .updateUserCoverImage(user: user, coverImage: image);
    return userUpdated;
  }
}
